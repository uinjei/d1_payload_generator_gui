import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DividerTheme(data: DividerThemeData(space: 10.0), child: Divider());
  }
}

class CustomDividerNoSpace extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DividerTheme(data: DividerThemeData(space: 0.0), child: Divider());
  }
}