import 'package:flutter/material.dart';
import 'home_widget.dart';
//import 'AppFooter.dart';

void main() {
  runApp(MyApp());
}

/// This is the main application widget.
class MyApp extends StatelessWidget {
  static const String _title = 'ChoreMate';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      theme: new ThemeData(primarySwatch: Colors.lightBlue),
      home: Home(),
    );
  }
}
