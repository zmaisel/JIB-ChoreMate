import 'package:choremate/custom%20widgets/CustomWidget.dart';
import 'package:choremate/models/groupModel.dart';
import 'package:choremate/models/userModel.dart';
import 'package:choremate/screens/createGroup/createGroup.dart';
import 'package:choremate/screens/root/root.dart';
import 'package:choremate/services/auth.dart';
import 'package:choremate/services/dbFuture.dart';
import 'package:choremate/services/dbStream.dart';
//import 'package:choremate/states/currentUser.dart';
import 'package:choremate/widgets/shadowContainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:choremate/screens/todo.dart';
import 'package:choremate/models/task.dart';

import 'package:choremate/screens/calendar.dart';

class UserData extends StatefulWidget {
  final UserModel userModel;
  //final GroupModel groupModel;

  UserData({
    this.userModel,
  });

  @override
  UserDataState createState() => UserDataState();
}

class UserDataState extends State<UserData> {
  final key = new GlobalKey<ScaffoldState>();
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<String> numIncompleteChores() async {
    List<Task> incompleteChores = await DBFuture()
        .getUserChoreList(widget.userModel.uid, widget.userModel.groupId);
    if (incompleteChores == null) {
      return "0";
    }
    return incompleteChores.length.toString();
  }

  Future<String> numCompleteChores() async {
    List<Task> completeChores = await DBFuture()
        .getUserCompletedList(widget.userModel.uid, widget.userModel.groupId);

    if (completeChores == null) {
      return "0";
    }
    return completeChores.length.toString();
  }

  Future<List<String>> userData() async {
    List<String> userData = List();
    String incompleteChores = await numIncompleteChores();
    userData.add(incompleteChores);
    String completeChores = await numCompleteChores();
    userData.add(completeChores);
  }

  int index = 0;

  @override
  Widget build(BuildContext context) {
    Color green = const Color(0xFFa8e1a6);
    Color blue = const Color(0xFF5ac9fc);
    return Scaffold(
      appBar: AppBar(
        title: Text('ChoreMate'),
        backgroundColor: blue,
      ),
      body: (ListView(
        children: [
          FutureBuilder(
              future: numIncompleteChores(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                return ListTile(
                    title: Text("Incomplete Chores: " + snapshot.data));
              })
        ],
      )),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index, // this will be set when a new tab is tapped
        onTap: (int index) {
          setState(() {
            this.index = index;
          });
          switch (index) {
            case 0:
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => OurRoot(),
                ),
                (route) => false,
              );
              break;
            case 1:
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => todo(userModel: widget.userModel),
                ),
                (route) => false,
              );
              break;
            case 2:
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => calendar(userModel: widget.userModel),
                ),
                (route) => false,
              );
              break;
          }
        },
        fixedColor: green,
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.home),
            title: new Text('Home'),
            backgroundColor: blue,
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.cleaning_services),
            title: new Text('Chores'),
            backgroundColor: blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            title: Text('Calendar'),
            backgroundColor: blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            title: Text('Notifcations'),
            backgroundColor: blue,
          )
        ],
      ),
    );
  }
}
