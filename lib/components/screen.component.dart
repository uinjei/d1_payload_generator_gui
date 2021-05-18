import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:d1_payload_generator_gui/components/leftside.component.dart';
import 'package:d1_payload_generator_gui/components/rightside.component.dart';
import 'package:d1_payload_generator_gui/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Screen extends StatelessWidget {
  final page = ValueNotifier("Editor");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<String>(
        valueListenable: page,
        builder: (content, value, child) {
          return WindowBorder(
            width: 1,
            color: borderColor,
            child: Row(
              children: [
                LeftSide(page),
                RightSide(page)
              ],
            ),
          );
        },
      )
    );
  }
}