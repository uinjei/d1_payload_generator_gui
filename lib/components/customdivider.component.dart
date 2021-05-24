import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DividerTheme(data: DividerThemeData(space: 10.0), child: Divider());
  }
}