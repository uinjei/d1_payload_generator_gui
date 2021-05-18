import 'package:d1_payload_generator_gui/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CustomTextBox extends StatelessWidget {

  
  final String label;
  final TextEditingController? controller;

  CustomTextBox({Key? key, required this.label, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: TextField(
        style: textBlack,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: textBlack
        ),
        controller: controller,
      ),
    );
  }
  
}