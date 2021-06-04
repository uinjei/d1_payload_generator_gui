import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

class TextBoxSmall extends StatelessWidget {

  
  final String label;
  final TextEditingController? controller;
  final bool enabled;

  TextBoxSmall({Key? key, required this.label, required this.controller, this.enabled = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoFormRow(
      child: CupertinoTextField(
        enabled: enabled,
        prefix: Padding(
          padding: EdgeInsets.only(left: 5, right: 5),
          child: Text("$label:"),
        ),
        style: TextStyle(
          fontSize: 14
        ),
        controller: controller,
    ),);
  }
  
}