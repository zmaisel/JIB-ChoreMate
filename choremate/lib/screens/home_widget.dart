import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//import 'package:choremate/screens/chores.dart';
//import 'package:choremate/screens/todo.dart';

void main() => runApp(Home());

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ChoreMate'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index, // this will be set when a new tab is tapped
        onTap: (int index) {
          setState(() {
            this.index = index;
          });
          switch (index) {
            case 0:
              Navigator.of(context).pushNamed('/home');
              break;
            case 1:
              Navigator.of(context).pushNamed('/todo');
              break;
            case 2:
              Navigator.of(context).pushNamed('/Calendar');
              break;
          }
        },
        fixedColor: Colors.lightGreen,
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.home),
            title: new Text('Home'),
            backgroundColor: Colors.lightBlue,
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.cleaning_services),
            title: new Text('Chores'),
            backgroundColor: Colors.lightBlue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            title: Text('Calendar'),
            backgroundColor: Colors.lightBlue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            title: Text('Notifcations'),
            backgroundColor: Colors.lightBlue,
          )
        ],
      ),
    );
  }
}
