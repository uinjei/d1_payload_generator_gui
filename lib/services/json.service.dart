import 'dart:convert';
import 'package:d1_payload_generator_gui/services/io.services.dart';

dynamic loadSettings() async {
  return await readFile("./settings.json");
}

Future<dynamic> saveSettings(data) async {
  return await writeFile("./settings.json", data);
}

Future<dynamic> savePayload(path, data) async {
  return await writeFile(path, data);
}

dynamic toJson(String jsonString) => json.decode(jsonString);

String indentJson(jsonObject) {
  final encoder = new JsonEncoder.withIndent("    ");
  return encoder.convert(jsonObject);
}