import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:d1_payload_generator_gui/components/windowbutton.component.dart';
import 'package:d1_payload_generator_gui/pages/generate.page.dart';
import 'package:d1_payload_generator_gui/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

const backgroundStartColor = Color(0xFFFFFFFF);
const backgroundEndColor = Color(0xFF702963);

class RightSide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [backgroundStartColor, backgroundEndColor],
          stops: [0.0, 1.0]
        )
      ),
      child: Column(children: [
        WindowTitleBarBox(
          child: Row(
            children: [
              Expanded(child: MoveWindow()),
              WindowButtons()
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Align(
          alignment: Alignment.centerLeft,
          child: Text("Generate Payload", style: titleText,),
        ),
        ),
        Expanded (
            child: GeneratePage(),
        ),
        ],
      ),
    ));
  }
  
}