import 'dart:convert';
import 'package:d1_payload_generator_gui/services/io.services.dart';

dynamic loadSettings() async {
    return await readFile('./settings.json');
}

dynamic toJson(String jsonString) => json.decode(jsonString);

String encoderWithInd(jsonObject) {
  final encoder = new JsonEncoder.withIndent("    ");
  return encoder.convert(jsonObject);
}