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

  final util = Util();
  final _buildOrderItems = BuildOrderItems();

  findPrice(args) async {
    final List<dynamic> spoPrice = args["spoPrice"];
    final priceCharacteristic = spoPrice.map((price) async {
      String filename = util.generateJSONFileLocation(PRODUCT_PRICE_FOLDER, price["id"]);
      
      dynamic jsonFile = await readFile(filename);
      
      Map priceMap;

      if (jsonFile["priceType"] == "RC") {

          final paymentTiming = jsonFile["priceCharacteristic"].firstWhere((result) => result["name"] == "Payment timing");
          final prorationMethod = jsonFile["priceCharacteristic"].firstWhere((result) => result["name"] == "Proration Method");

          priceMap = {
              "rc" : {
                 "timing": paymentTiming!=null?paymentTiming["characteristicValue"][0]["value"]:"NO_PAYMENT_TIMING",
                 "proration": prorationMethod!=null?prorationMethod["characteristicValue"][0]["value"]:"NO_PRORATION_METHOD"
              }
          };
      }
      else priceMap = {"oc": "OC"};
      return priceMap;

    }).toList();
    
    final priceCharacteristics = await Future.wait(priceCharacteristic);
    
    final rc = priceCharacteristics.firstWhere((result) => result["rc"]!=null, orElse: () => Map());

    String paymentTiming = "";
    String prorationMethod = "";

    if (rc.isNotEmpty) {
      paymentTiming = rc["rc"]["timing"];
      prorationMethod = rc["rc"]["proration"];
    } else {
      paymentTiming = "NO";
      prorationMethod = "RC";
    }

    return {
        ...args,
        "timing": paymentTiming,
        "proration": prorationMethod
    };
  }

  dynamic findMainSpoPrice(args) async {
      String filename = util.generateJSONFileLocation(PRODUCT_OFFERING_FOLDER, args["mainSpoId"]);
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
      final onNetIndicator = _buildOrderItems.selectOnNetIndicator(util.offNet3rdPartyProvider);

      final offerGroupOrders = await _buildOrderItems.generateOfferGroupOrder(bundledProduct["bundledProdOfferGroupOption"]);

      final orderItems = await _buildOrderItems.createOrderItems([...bundledProduct["bundledProductOffering"],...offerGroupOrders],
        onNetIndicator);
      
      mainOrder["orderItem"] = orderItems;
      
      payload["orderItem"].add(mainOrder);

      final mainSpoId = getMainSpo(bundledProduct["bundledProductOffering"]);
      
      return {
          "id" : bundledProduct["id"],
          "name": (util.getLocaleValue(bundledProduct["localizedName"]) as String).replaceAll(RegExp(r'[^\w\s]'), ' '),
          "currency": getCurrency(bundledProduct["currency"]),
          "mainSpoId": mainSpoId,
          "payload": payload
      };
  }

  Future<void> reloadSettings() async {
    await util.reloadSettings();
  }
  
  getGeneratedPayloadList() => util.bpoIds.map((id) async {
      _logger.info("Generating Provide Payload: " + id);

      final filename = util.generateJSONFileLocation(PRODUCT_OFFERING_FOLDER, id);
      return await readFile(filename)
          .then(buildPayload)
          .then(findMainSpoPrice)
          .then(findPrice)
          .then(util.writeToJSONFile)
          /* .catchError((error) => error) */;
  });

  handleError(result) {
    final errorJSON = {};

    var errorCount = result.where((error) => error is NotABundleException).length;

    _logger.info("Successfully generated ${result.length - errorCount} payloads.");

    if (errorCount > 0) {
        _logger.info("Error found in $errorCount file(s)");

        result.asMap().forEach((i, error) {
            if (error is NotABundleException) {
                errorJSON[util.bpoIds[i]] = error.cause;
            }
        });

        writeFile('${util.outputFolder}/error-${_formatter.format(DateTime.now())}.json', indentJson(errorJSON));
    }
  }
 
}