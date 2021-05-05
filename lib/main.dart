import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import './components/leftside.component.dart';
import './components/rightside.component.dart';
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
    final initialSize = Size(1000, 720);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.title = "D1 Payload Generator";
    appWindow.show();

    logger.info("Application Started");

  });
}

const borderColor = Color(0xFF7AD7F0);

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: WindowBorder(
          width: 1,
          color: borderColor,
          child: Row(
            children: [
              LeftSide(),
              RightSide()
            ],
          ),
        ),
      ),
    );
  }
}