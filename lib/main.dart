import 'dart:io';

import 'package:d1_payload_generator_gui/components/screen.component.dart';
import 'package:d1_payload_generator_gui/globals.dart';
import 'package:d1_payload_generator_gui/pages/editor.page.dart';
import 'package:d1_payload_generator_gui/pages/generate.page.dart';
import 'package:d1_payload_generator_gui/style.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

File outputFile = File('app.log');

void main() {

  final logger = Logger('Main');

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
      stdout.writeln("${rec.time} | ${rec.level} | ${rec.loggerName} | ${rec.message}");
      outputFile.writeAsStringSync("${rec.time} | ${rec.level} | ${rec.loggerName} | ${rec.message} \n", mode: FileMode.append);
  });

  runApp(MyApp());

  doWhenWindowReady(() {
    final initialSize = Size(1000, 760);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.title = "D1 Payload Generator";
    appWindow.show();

    logger.info("Application Started");

  });
}

const borderColor = Color(0xFFBF40BF);

class MyApp extends StatelessWidget {

 @override
    Widget build(BuildContext context) {
      return new MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: appTheme,
        navigatorKey: AppGlobals.rootNavKey,
        home: Screen(),
        routes: {
          "generate": (BuildContext context) => GeneratePage(),
          "editor": (BuildContext context) => EditorPage(),
        },
      );
  }
}