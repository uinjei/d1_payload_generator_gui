import 'package:d1_payload_generator_gui/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

class TextBoxWithButton extends StatelessWidget {

  
  final String label;
  final TextEditingController controller;
  final Icon icon;
  final Function onPressed;

  TextBoxWithButton({Key? key, required this.label, required this.controller, required this.icon, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoFormRow(
      child: CupertinoTextField.borderless(
        style: textBlack,
        prefix: Text("$label:"),
        suffix: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: CupertinoButton(
            child: icon,
            onPressed: () {
              onPressed();
            },
          ),
        ),
        controller: controller,
      ),
    );
  }
  
}