import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:d1_payload_generator_gui/pages/editor.page.dart';
import 'package:d1_payload_generator_gui/pages/generate.page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

const sidebarColor = Color(0xFFBF40BF);

class LeftSide extends StatelessWidget {

  final ValueListenable<String> page;

  LeftSide(this.page);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      child: Container(color: sidebarColor,
        child: Column(
          children: [
            WindowTitleBarBox(
              child: MoveWindow(),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  return IconButton(
                    icon: Icon(pages[index]["icon"]),
                    onPressed: () {pages[index]["onPressed"](page);},
                  );
              }) 
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
    "icon": Icons.folder_open,
    "onPressed": (page) { page.value = "Editor";}
  },
  {
    "name": "Generate",
    "title": "Generate Payload",
    "page": generate,
    "icon": Icons.flight_land,
    "onPressed": (page) { page.value = "Generate";}
  }
];