import 'package:d1_payload_generator_gui/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MultilineTextBox extends StatelessWidget {

  
  final String label;
  final TextEditingController controller;

  MultilineTextBox({Key? key, required this.label, required this.controller}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: TextFormField(
        style: whiteText,
        maxLines: 8,
        maxLength: 1000,
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(
          border: UnderlineInputBorder(),
          labelText: label,
          labelStyle: whiteText
        ),
        controller: controller,
      ),
    );
  }
  
}