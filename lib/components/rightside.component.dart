import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:d1_payload_generator_gui/components/leftside.component.dart';
import 'package:d1_payload_generator_gui/components/windowbutton.component.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

const backgroundStartColor = Color(0xFFFFFFFF);
const backgroundEndColor = Color(0xFF22316C);

class RightSide extends StatelessWidget {
  final ValueListenable<String> page;

  RightSide(this.page);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withOpacity(0.02), Colors.black.withOpacity(0.02)],
          stops: [0.0, 1.0]
        )
      ),
      child: Column(children: [
        WindowTitleBarBox(
          child: Row(
            children: [
              Expanded(child: MoveWindow(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                      child: Text(pages.firstWhere((element) => element["name"]==page.value)["title"]),
                    )
                  )
                ),
              ),
              WindowButtons()
            ],
          ),
        ),
        Expanded (
            child: (pages.firstWhere((element) => element["name"]==page.value)["page"] as Widget)
        ),
        ],
      ),
    ));
  }
  
}