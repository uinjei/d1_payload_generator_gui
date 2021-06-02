import 'dart:io';

import 'package:d1_payload_generator_gui/components/screen.component.dart';
import 'package:d1_payload_generator_gui/globals.dart';
import 'package:d1_payload_generator_gui/services/io.services.dart';
import 'package:d1_payload_generator_gui/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:oktoast/oktoast.dart';

File outputFile = File("app.log");
DateTime today = DateTime.now();
final df = DateFormat("MM-dd-yyyy");

void main() async {
  if (df.format(await outputFile.lastModified())!=df.format(today)) {
    outputFile.copySync("app_${df.format(DateTime.now().subtract(Duration(days: 1)))}.log");
    outputFile.writeAsString("");
  }

  final logger = Logger('Main');

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
      stdout.writeln("${rec.time} | ${rec.level} | ${rec.loggerName} | ${rec.message}");
      outputFile.writeAsStringSync("${rec.time} | ${rec.level} | ${rec.loggerName} | ${rec.message} \n", mode: FileMode.append);
  });

  runApp(MyApp());

  doWhenWindowReady(() {
    final initialSize = Size(1000, 725);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.title = "D1 Payload Generator";
    appWindow.show();

    logger.info("Application Started");

  });
}

class MyApp extends StatelessWidget {

 @override
    Widget build(BuildContext context) {
      return OKToast(
        child: CupertinoApp(
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          debugShowCheckedModeBanner: false,
          theme: cupAppTheme,
          navigatorKey: AppGlobals.rootNavKey,
          home: Screen(),
        )
      );
  }
}