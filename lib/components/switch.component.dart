import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CustomSwitch extends StatelessWidget {

  
  final String label;
  final bool value;
  final Function onChanged;

  CustomSwitch({Key? key, required this.label, required this.value, required this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Switch(
            value: value,
            onChanged: (newValue) {
              onChanged(newValue);
            },
          ),
        ],
      )
    );
  }
  
}