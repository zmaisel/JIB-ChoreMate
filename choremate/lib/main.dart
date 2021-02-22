//import 'dart:html';

import 'package:flutter/material.dart';
import 'package:choremate/screens/home_widget.dart';
import 'package:choremate/screens/todo.dart';
import 'package:choremate/services/auth.dart';
import 'package:provider/provider.dart';
import 'package:choremate/models/authModel.dart';
import 'package:choremate/screens/root/root.dart';
import 'package:choremate/states/currentUser.dart';
//import 'AppFooter.dart';

void main() {
  runApp(MyApp());
}

final routes = {
  '/todo': (context) => todo(),
  '/home': (context) => Home(),
};
//   '/login': (BuildContext context) => new LoginPage(),

//   '/register': (BuildContext context) => new RegisterPage(),

//   '/': (BuildContext context) => new LoginPage(),

class MyApp extends StatelessWidget {
  static const String _title = 'ChoreMate';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => CurrentUser(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: OurRoot(),
          title: _title,
          theme: new ThemeData(primarySwatch: Colors.lightBlue),
          routes: routes,
        ));
  }
}
