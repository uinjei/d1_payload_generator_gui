

import 'dart:io';

import 'package:d1_payload_generator_gui/services/json.service.dart';
import 'package:d1_payload_generator_gui/utils/util.dart';
import 'package:logging/logging.dart';

final _logger = Logger('IO');

Future<File> _localFile(String path) async {
  return File(path);
}

Future<dynamic> readFileMeta(String location) async {
    final file = await _localFile(location);
    String contents = await file.readAsString();
    final c = contents.split("**/");
    return toJson(c[0].replaceAll(RegExp(r'/\*\*SYSTEM GENERATED DO NOT INCLUDE THIS COMMENT IN YOUR PAYLOAD'), ""));
}

Future<dynamic> readFileContent(String location) async {
    final file = await _localFile(location);
    String contents = await file.readAsString();
    final c = contents.split("**/");
    return toJson(c[1]);
}

Future<dynamic> readFile(String location) async {
  try {
    final file = await _localFile(location);

    String contents = await file.readAsString();

    return toJson(contents);

  } catch (e) {
    _logger.severe((e as Exception).toString());
  }
}

Future<dynamic> writeFile(String location, String json) async {
  final file = await _localFile(location);
  return file.writeAsString(json);
}

getCurrency(contents) => contents["defaultCurrency"];

getMainSpo(contents) =>
  contents.firstWhere((content) => content["bundledProdOfferOption"]["numberRelOfferLowerLimit"] == 1 &&
  content["bundledProdOfferOption"]["numberRelOfferUpperLimit"] == 1 && content["bundledProdOfferOption"]["defaultRelOfferNumber"] == 1
)["id"];