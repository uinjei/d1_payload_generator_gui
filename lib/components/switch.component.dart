import 'package:d1_payload_generator_gui/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

class CustomSwitch extends StatelessWidget {

  
  final String label;
  final bool value;
  final Function onChanged;

  CustomSwitch({Key? key, required this.label, required this.value, required this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoFormRow(child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textBlack,),
          Transform.scale(
            scale: 0.6,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: CupertinoSwitch(
                value: value,
                onChanged: (newValue) {
                  onChanged(newValue);
                },
              ),
            )
          ),
        ],
    ),);
  }
  
}