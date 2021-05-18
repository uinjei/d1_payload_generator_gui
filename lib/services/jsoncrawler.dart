

import 'package:d1_payload_generator_gui/components/textbox.component.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

final _logger = Logger("Crawler");

Widget crawlah(json, parent) {

  if (json is String) {
    _logger.info("json is string end>> " + json);
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
      child: CustomTextBox(
        controller: TextEditingController(),
        label: "$parent",
      ),
    );
  } else if (json is int) {
    _logger.info("json is int end>> " + json.toString());
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
      child: CustomTextBox(
        controller: TextEditingController(),
        label: "$parent",
      ),
    );
  } else if (json is List<dynamic>) {
    _logger.info("json is list dynamic do recurse.");
    return Padding(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: json.map((element) {
              return crawlah(element, "$parent[]");
            }).toList(),
        ),
      );
  } /* else if (json is List<String>) {
    _logger.info("json is list string do recurse.");
    crawler(json);
    json.forEach((element) {
      crawler(element);
    });
  } */ else if (json is Map) {
    _logger.info("json is map do recurse.");
    final keys = json.keys;
    return Padding(
        padding: EdgeInsets.fromLTRB(10, 0, 0, 0), 
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("$parent:"),
              ...keys.map((key) {
            _logger.info("with key: " + key);
            return crawlah(json[key], key);
          }).toList()],
        )
    );
  }
  return Container();
}