import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CustomTextBox extends StatelessWidget {

  
  final String label;
  final TextEditingController controller;

  CustomTextBox({Key? key, required this.label, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: TextFormField(
        decoration: InputDecoration(
          border: UnderlineInputBorder(),
          labelText: label,
        ),
        controller: controller,
      ),
    );
  }
  
}