import 'dart:convert';

import 'package:d1_payload_generator_gui/services/io.services.dart';
import 'package:d1_payload_generator_gui/services/json.service.dart';
import 'package:d1_payload_generator_gui/utils/constants.util.dart';

  class Util {

    List bpoIds = [];
    String fdLocation = "";
    String outputFolder = "";
    bool pretty = true;
    bool allowRandomQty = true;
    bool includeAllSpo = true;
    bool offNet3rdPartyProvider = true;
    List productOffersWithPlace = [];

    Util() {
      _loadSettings();
    }

    Future<void> _loadSettings() async {
      final data = await loadSettings();
      bpoIds = data[BPO_IDs];
      fdLocation = data[FD_LOCATION];
      outputFolder = data[OUTPUT_FOLDER];
      pretty = data[PRETTY];
      allowRandomQty = data[ALLOW_RANDOM_QTY];
      includeAllSpo = data[INCLUDE_ALL_SPO];
      offNet3rdPartyProvider = data[OFF_NET_3RD_PARTY_PROVIDER];
      productOffersWithPlace = data[PRODUCT_OFFERS_WITH_PLACE];
    }

    Future<void> reloadSettings() async {
      await _loadSettings();
    }

    getLocaleValue(contents) => contents.firstWhere((content) => LOCALE == content["locale"])["value"];
      
    generateJSONFileLocation(String type, String id) => '$fdLocation/$type/$id.json';

    writeToJSONFile(args) => writeFile('$outputFolder/${args["name"]}_${args["currency"]}_${args["timing"]}_${args["proration"]}.json', 
        pretty?indentJson(args["payload"]): json.encode(args["payload"]));

}
