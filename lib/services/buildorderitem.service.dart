import 'dart:math';
import 'package:d1_payload_generator_gui/services/io.services.dart';
import 'package:d1_payload_generator_gui/utils/constants.util.dart';
import 'package:d1_payload_generator_gui/utils/util.dart';
import 'package:logging/logging.dart';

final _logger = Logger("Generator");

class BuildOrderItems {

  final util = Util();

  createBillingAccountField() =>  {
      "id": "{{billing}}"
  };
  
  createExternalIdentifierField(type, orderCount) {

      List<dynamic> externalIdentifier = [];

      switch (type) {
          case BUNDLE_PRODUCT_TYPE:
              externalIdentifier.add({
                  "id": "Vlocity_OrderItemID",
                  "type": "VlocityOrderItem"
              });
              break;
          case SIMPLE_PRODUCT_TYPE:
              externalIdentifier.add({
                  "id": 'Vlocity_OrderItemID_$orderCount',
                  "type": "VlocityOrderItem"
              });
              externalIdentifier.add({
                  "id": 'NCSOM_OrderItemID_$orderCount',
                  "type": "NCSOM Product"
              });
              break;
          case ROOT_TYPE:
          default:

              externalIdentifier.add({
                  "id": "Vlocity_OrderID",
                  "type": "VlocityOrder"
              });
              externalIdentifier.add({
                  "id": "NCSOM_OrderID",
                  "type": "NCSOM External"
              });
              
      }
      return externalIdentifier;
  }

  createBasicPayload() {

      dynamic payload = {
          "relatedParty": [
              {
                  "role": "customer",
                  "id": "{{CustomerId}}"
              }
          ],
          "orderItem": [],
          "billingAccount": createBillingAccountField(),
          "externalIdentifier": createExternalIdentifierField(ROOT_TYPE, 0)
      };
      
      return payload;
  }

  createMainOrder(mainProductOfferingId, cardinality) {

      dynamic mainOrder = createBaseOrderItem(mainProductOfferingId, cardinality);

      mainOrder["billingAccount"] = createBillingAccountField();
      mainOrder["externalIdentifier"] = createExternalIdentifierField(BUNDLE_PRODUCT_TYPE, 0);
      return mainOrder;
  }

  generateValue(type) {
      switch (type) {
          case STRING_TYPE:
              return "Random String";
          case INTEGER_TYPE:
              return generateRandomNumber(1, 100);
      }
  }

  selectValueFromProductOfferDefinedProductSpecCharValues(productOfferId) async {

      final filename = util.generateJSONFileLocation(PRODUCT_OFFERING_FOLDER, productOfferId);
      final json = await readFile(filename);
      final place = util.productOffersWithPlace.contains(util.getLocaleValue(json["localizedName"])) ? generatePlace(): false;

      final characteristic = json["prodSpecCharValueUse"].map((content) {
        final characteristicValue = content["characteristicValue"] as List<dynamic>;
        return {
            "name":content["name"],
            "value": characteristicValue.length>0?
            characteristicValue[generateRandomNumber(0, characteristicValue.length)]["value"]:
            generateValue(content["valueType"])
        };
      }).toList();

      return {
          "characteristic": characteristic,
          "productSpecification":json["productSpecification"],
          "productOfferingTerm":json["productOfferingTerm"],
          "place": place
      };
  }

  generatePlace() => ([
      {
          "role": "installation",
          "name": "installation",
          "id": "{{installation}}"
      }
  ]);

  selectValueFromProductSpecCharValues(productSpecId, characteristic, onNetIndicator) async {

      final filename = util.generateJSONFileLocation(PRODUCT_SPEC_FOLDER, productSpecId);

      final productSpec = await readFile(filename);

      final addedCharacteristics = characteristic.map((char) => char["name"]).toList();

      productSpec["productSpecCharacteristic"]
          .where((char) => !addedCharacteristics.contains(char["name"]))
          .forEach((char) => {
              if (char["name"] == "ipAddress")
                  characteristic.add({
                      "name": char["name"],
                      "value": "10.10.10.10"
                  })
              else if (char["name"] == "onNetIndicator" && char["productSpecCharacteristicValue"].length>0) {
                  characteristic.add({
                      "name": char["name"],
                      "value": char["productSpecCharacteristicValue"][onNetIndicator]["value"]
                  })
              } else
                  characteristic.add({
                      "name": char["name"],
                      "value": char["productSpecCharacteristicValue"].length>0 ?
                          char["productSpecCharacteristicValue"][generateRandomNumber(0, char["productSpecCharacteristicValue"].length)]["value"]
                          : generateValue(char["valueType"])
                  })
          });

      return characteristic;
  }

  selectProductsFromOfferGroup(List<dynamic> productOfferingsInGroup, min, max, defaultValue) {

      final cardinality = {
          "min": min,
          "max": max,
          "default": defaultValue
      };

      final quantity = generateQuantity(cardinality);

      List<dynamic> currentOffers = productOfferingsInGroup.where((productOffering) => !productOffering["expiredForSales"]).toList();
      List<dynamic> selectedOffers = [];

      for (int i = 0; i < quantity; i++) {
          final selectedIndex = generateRandomNumber(0, currentOffers.length);
          selectedOffers.add(currentOffers[selectedIndex]);
      }

      return selectedOffers;

  }

  convertOfferGroupToProductOffering(List<dynamic> offerGroup) {
      final selectedOffers = offerGroup.expand((i) => i).toList();
      final uniqueOffers = [...Set.from(selectedOffers)].map((uniqueOffer) {
          
          final count = selectedOffers.where((selectedOffer) => selectedOffer["id"] == uniqueOffer["id"]).length;

          return {
              "bundledProdOfferOption": {
                  "defaultRelOfferNumber": count,
                  "numberRelOfferLowerLimit": count,
                  "numberRelOfferUpperLimit": count
              },
              "expiredForSales": false,
              "id": uniqueOffer["id"],
              "groupOptionId": uniqueOffer["groupOptionId"]
          };
      }).toList();
      return uniqueOffers;
  }

  bool isLastMileOrAdditionalEquipment(offer) => 
      offer["name"][0]["value"] != "Select Last Mile Equipment" && offer["name"][0]["value"] != "Select Additional Equipment";



  generateOfferGroupOrder(List<dynamic> offerGroup) async {

      final List<dynamic> offers = util.offNet3rdPartyProvider ? offerGroup.where(isLastMileOrAdditionalEquipment).toList() : offerGroup;

      final list = offers.map((productOffer) async {
          final filename = util.generateJSONFileLocation(PRODUCT_OFFERING_GROUP_FOLDER, productOffer["bundledGroupPolicy"]["id"]);
          final offerGroup = await readFile(filename);
          final selectedOrders = selectProductsFromOfferGroup(
              offerGroup["productOfferingsInGroup"],
              productOffer["numberRelOfferLowerLimit"],
              productOffer["numberRelOfferUpperLimit"],
              productOffer["bundledGroupPolicy"]["defaultRelOfferNumber"]
          );

          selectedOrders.forEach((selectedOrder) => selectedOrder["groupOptionId"] = productOffer["groupOptionId"]);
          return selectedOrders;
      }).toList();
      
      return convertOfferGroupToProductOffering(await Future.wait(list));
  }


  addItemTerm(productOfferingTerm) {

      final index = generateRandomNumber(0, productOfferingTerm.length);
      final selectedTerm = productOfferingTerm[index];

      return {
          "duration": selectedTerm["duration"],
          "policyId": selectedTerm["policy"]["id"],
          "@type": selectedTerm["type"],
          "name": selectedTerm["name"]
      };
  }

  createProductDetails(productOfferId, onNetIndicator) async {
      
      final json = await selectValueFromProductOfferDefinedProductSpecCharValues(productOfferId);

      await selectValueFromProductSpecCharValues(json["productSpecification"]["id"], json["characteristic"], onNetIndicator);

      final itemTerm = [];
      if (json["productOfferingTerm"].length > 0) {
          itemTerm.add(addItemTerm(json["productOfferingTerm"]));
      }

      final product = {
          "productSpecification": json["productSpecification"],
          "characteristic": json["characteristic"],
          "place": json["place"]
      };

      if(product["place"] is bool && !product["place"]) product.remove("place");

      return {
          "product": product,
          "itemTerm": itemTerm
      };
  }

  selectOnNetIndicator(is3rdParty) => is3rdParty ? 1 : 0;

  addGroupOptionId(orderItem, groupOptionId) => orderItem["productOfferingGroupOption"] = { "groupOptionId": groupOptionId};

  createOrderItems(List productOfferings, onNetIndicator) async {
        final orderitems = productOfferings.asMap().entries.map((entry) async {
          int key = entry.key;
          dynamic value = entry.value;

          final cardinality = {
              "min": value["bundledProdOfferOption"]["numberRelOfferLowerLimit"],
              "max": value["bundledProdOfferOption"]["numberRelOfferUpperLimit"],
              "default": value["bundledProdOfferOption"]["defaultRelOfferNumber"]
          };

          final orderItem = createBaseOrderItem(value["id"], cardinality);
          
          orderItem["externalIdentifier"] = createExternalIdentifierField(SIMPLE_PRODUCT_TYPE, key + 1);
          
          if (value["groupOptionId"]!=null) addGroupOptionId(orderItem, value["groupOptionId"]);

          final productDetails = await createProductDetails(value["id"], onNetIndicator);

          orderItem["product"] = productDetails["product"];

          if (productDetails["itemTerm"].length > 0) orderItem["itemTerm"] = productDetails["itemTerm"];

          if (orderItem["product"]["productSpecification"]["id"] == "a0bba909-01a0-4ab7-87d1-bdfe3e6329bd") addNextActionField(orderItem);

          return orderItem;
      }).toList();
      
      return await Future.wait(orderitems);
  }

  addNextActionField(orderItem) => orderItem["nextAction"] = [
      {
          "durationPolicy": {
              "duration": {
                  "amount": 2,
                  "units": "Months"
              },
              "startDatePolicy": "activationDate"
          },
          "action": "terminate",
          "nextActionType": "customerDefined",
          "extensions": {
              "requestType": "Future"
          }
      }
  ];

  generateRandomNumber(int min, int max) => (Random().nextInt(max)).floor() + min;

  generateQuantity(cardinality) {

      int quantity = 1;
      if (cardinality!=null) return quantity;

      if (cardinality!=null && util.allowRandomQty) {
          int min = util.includeAllSpo ? 1 : ((cardinality["min"] || cardinality["default"]) as int);
          quantity = generateRandomNumber(min, cardinality.max);
      } else if (cardinality!=null && !util.allowRandomQty) {
          int min = util.includeAllSpo ? 1 : ((cardinality["min"] || cardinality["default"]) as int);
          quantity = min;
      }

      return quantity;
  }

  createBaseOrderItem(productOfferingId, cardinality) {

      final quantity = generateQuantity(cardinality);
      
      if (quantity == 0) return null;

      return {
          "extensions": {
              "reservationId": "123"//leave as is
          },
          "quantity": quantity.toString(),
          "productOffering": {
              "id": productOfferingId
          },
          "action": "add",
          "modifyReason": [
              {
                  "name": "CREQ",
                  "action": "add"
              }
          ]
      };
  }
}

