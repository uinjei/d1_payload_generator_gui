import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/widgets.dart';

const sidebarColor = Color(0xFFBF40BF);

class LeftSide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Container(color: sidebarColor,
        child: Column(
          children: [
            WindowTitleBarBox(
              child: MoveWindow(),
            ),
          ],
        )
      )
    );
  }
  
}