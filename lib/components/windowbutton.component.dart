import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final buttonColors = WindowButtonColors(
  iconNormal: Color(0xFF7AD7F0),
  mouseOver: Color(0xFFDBF3FA),
  mouseDown: Color(0xFF7AD7F0),
  iconMouseOver: Color(0xFF7AD7F0),
  iconMouseDown: Color(0xFFFFFFFF)
);

final closeButtonColors = WindowButtonColors(
    mouseOver: Color(0xFFD32F2F),
    mouseDown: Color(0xFFB71C1C),
    iconNormal: Color(0xFF805306),
    iconMouseOver: Colors.white
);

class WindowButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors,),
        MaximizeWindowButton(colors: buttonColors,),
        CloseWindowButton(colors: closeButtonColors,),
      ],
    );
  }
  
} 