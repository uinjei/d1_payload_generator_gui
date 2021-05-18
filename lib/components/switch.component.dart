import 'package:d1_payload_generator_gui/style.dart';
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
          Text(label, style: textBlack,),
          Switch(
            activeColor: Colors.purple,
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