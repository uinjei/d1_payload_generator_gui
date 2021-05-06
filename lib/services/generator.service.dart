import 'dart:async';
import 'package:d1_payload_generator_gui/exceptions/custom.exception.dart';
import 'package:d1_payload_generator_gui/services/io.services.dart';
import 'package:d1_payload_generator_gui/services/json.service.dart';
import 'package:d1_payload_generator_gui/utils/constants.util.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:d1_payload_generator_gui/services/buildorderitem.service.dart';
import 'package:d1_payload_generator_gui/utils/util.dart';

import 'buildorderitem.service.dart';

class Generator {
  
  final _logger = Logger('Generator');

  final DateFormat _formatter = DateFormat('MMddyyyy_HHmmss');

  final _util = Util();
  final _buildOrderItems = BuildOrderItems();

  findPrice(args) async {
    final List<dynamic> spoPrice = args["spoPrice"];
    final priceCharacteristic = spoPrice.map((price) async {
      String filename = _util.generateJSONFileLocation(PRODUCT_PRICE_FOLDER, price["id"]);
      
      dynamic jsonFile = await readFile(filename);
      
      Map priceMap;

      if (jsonFile["priceType"] == "RC") {
          priceMap = {
              "timing": jsonFile["priceCharacteristic"].firstWhere((result) => result["name"] == "Payment timing")["characteristicValue"][0]["value"],
              "proration": jsonFile["priceCharacteristic"].firstWhere((result) => result["name"] == "Proration Method")["characteristicValue"][0]["value"]
          };
      }
      else priceMap = {"oc": "OC"};
      return priceMap;

    }).toList();
    
    final priceCharacteristics = await Future.wait(priceCharacteristic);
    
    return {
        ...args,
        "timing": priceCharacteristics.firstWhere((result) => result["timing"]!=null)["timing"],
        "proration": priceCharacteristics.firstWhere((result) => result["proration"]!=null)["proration"]
    };
  }

  dynamic findMainSpoPrice(args) async {
      String filename = _util.generateJSONFileLocation(PRODUCT_OFFERING_FOLDER, args["mainSpoId"]);
      dynamic jsonFile = await readFile(filename);

      return {
          ...args,
          "spoPrice": jsonFile["productOfferingPrice"]
      };
  }

  buildPayload(bundledProduct) async {

      if (!bundledProduct["isBundle"]) throw NotABundleException();

      final payload = _buildOrderItems.createBasicPayload();
      final mainOrder = _buildOrderItems.createMainOrder(bundledProduct["id"], null);
      final onNetIndicator = _buildOrderItems.selectOnNetIndicator(_util.offNet3rdPartyProvider);

      final offerGroupOrders = await _buildOrderItems.generateOfferGroupOrder(bundledProduct["bundledProdOfferGroupOption"]);

      final orderItems = await _buildOrderItems.createOrderItems([...bundledProduct["bundledProductOffering"],...offerGroupOrders],
        onNetIndicator);
      
      mainOrder["orderItem"] = orderItems;
      
      payload["orderItem"].add(mainOrder);

      final mainSpoId = getMainSpo(bundledProduct["bundledProductOffering"]);
      
      return {
          "name": (_util.getLocaleValue(bundledProduct["localizedName"]) as String).replaceAll(RegExp(r'[^\w\s]'), ' '),
          "currency": getCurrency(bundledProduct["currency"]),
          "mainSpoId": mainSpoId,
          "payload": payload
      };
  }

  
  getGeneratedPayloadList() => _util.bpoIds.map((id) async {
      _logger.info("Generating Provide Payload: " + id);

      final filename = _util.generateJSONFileLocation(PRODUCT_OFFERING_FOLDER, id);
      return await readFile(filename)
          .then(buildPayload)
          .then(findMainSpoPrice)
          .then(findPrice)
          .then(_util.writeToJSONFile)
          .catchError((error) => error);
  });

  handleError(result) {
    final errorJSON = {};

    var errorCount = result.where((error) => error is NotABundleException).length;

    _logger.info("Successfully generated ${result.length - errorCount} payloads.");

    if (errorCount > 0) {
        _logger.info("Error found in $errorCount file(s)");

        result.asMap().forEach((i, error) {
            if (error is NotABundleException) {
                errorJSON[_util.bpoIds[i]] = error.cause;
            }
        });

        writeFile('${_util.outputFolder}/error-${_formatter.format(DateTime.now())}.json', encoderWithInd(errorJSON));
    }
  }
 
}