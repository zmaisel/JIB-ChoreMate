import 'package:flutter/material.dart';
import 'home_widget.dart';
import 'package:choremate/chores.dart';
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
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/Chores': (context) => Chores(),
        '/Home': (context) => Home(),
        // When navigating to the "/second" route, build the SecondScreen widget.
        //add next route here
      },
    );
  }
}
