//import 'dart:html';

import 'package:flutter/material.dart';
//import 'package:choremate/screens/chores.dart';
import 'package:choremate/screens/home_widget.dart';
import 'package:choremate/screens/login/login_page.dart';
import 'package:choremate/screens/login/register.dart';
import 'package:choremate/screens/todo.dart';
//import 'AppFooter.dart';

void main() {
  runApp(MyApp());
}

final routes = {
  '/login': (BuildContext context) => new LoginPage(),
  '/home': (context) => Home(),
  '/register': (BuildContext context) => new RegisterPage(),
  '/todo': (context) => todo(),
  '/': (BuildContext context) => new LoginPage(),
};

class MyApp extends StatelessWidget {
  static const String _title = 'ChoreMate';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      theme: new ThemeData(primarySwatch: Colors.lightBlue),
      routes: routes,
    );
  }
}
