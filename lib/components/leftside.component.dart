import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:d1_payload_generator_gui/pages/editor.page.dart';
import 'package:d1_payload_generator_gui/pages/generate.page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

final _logger = Logger("Editor");

class LeftSide extends StatelessWidget {

  final ValueListenable<String> page;

  LeftSide(this.page);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      child: Container(color: CupertinoColors.activeBlue,
        child: Column(
          children: [
            WindowTitleBarBox(
              child: MoveWindow(),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: CupertinoButton(
                      child: Icon(pages[index]["icon"], color: pages[index]["name"]==page.value?Colors.white:Colors.white54,),
                      onPressed: () {pages[index]["onPressed"](page);},
                    )
                  );
                }
              ), 
            ),
          ],
        )
      )
    );
  }
  
}

final generate = GeneratePage();
final editor = EditorPage();

final List<Map> pages = [
  {
    "name": "Editor",
    "title": "Edit Payloads",
    "page": editor,
    "icon": CupertinoIcons.pencil_ellipsis_rectangle,
    "onPressed": (page) { page.value = "Editor";}
  },
  {
    "name": "Generate",
    "title": "Generate Payload",
    "page": generate,
    "icon": CupertinoIcons.gear,
    "onPressed": (page) { page.value = "Generate";}
  }
];