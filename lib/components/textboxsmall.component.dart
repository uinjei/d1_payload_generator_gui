import 'package:d1_payload_generator_gui/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TextBoxSmall extends StatelessWidget {

  
  final String label;
  final TextEditingController? controller;
  final bool enabled;

  TextBoxSmall({Key? key, required this.label, required this.controller, this.enabled = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
        enabled: enabled,
        style: TextStyle(
          fontSize: 14
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: textBlack,
          contentPadding: EdgeInsets.all(10),
          isDense: true,
        ),
        controller: controller,
    );
  }
  
}