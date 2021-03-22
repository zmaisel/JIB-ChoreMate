import 'dart:math';

import 'package:flutter/material.dart';
import 'package:choremate/utilities/databaseHelper.dart';
import 'package:choremate/models/task.dart';
import 'package:choremate/screens/todo.dart';
import 'package:choremate/utilities/utils.dart';
import 'package:choremate/screens/calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:choremate/services/dbFuture.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:choremate/screens/reminders.dart';

class new_reminder extends StatefulWidget {
  final String appBarTitle;
  final Reminder reminder;
  reminder_state remindersState;
  new_reminder(this.reminder, this.appBarTitle, this.remindersState);
  bool _isEditable = false;
  static ids = 0

  @override
  State<StatefulWidget> createState() {
    return message_state(this.reminder, this.appBarTitle, this.remindersState);
  }
}

class message_state extends State<new_reminder> {
  reminders_state remindersState;
  String appBarTitle;
  Reminder reminder;
  List<Widget> icons;
  reminder_state(this.reminder, this.appBarTitle, this.remindersState);

  bool marked = false;

  TextStyle titleStyle = new TextStyle(
    fontSize: 18,
    fontFamily: "Lato",
  );

  TextStyle buttonStyle =
      new TextStyle(fontSize: 18, fontFamily: "Lato", color: Colors.white);

  final scaffoldkey = GlobalKey<ScaffoldState>();

  DatabaseHelper helper = DatabaseHelper();
  Utils utility = new Utils();
  TextEditingController reminderController = new TextEditingController();

  var _minPadding = 10.0;

  @override
  Widget build(BuildContext context) {
    reminderController.text = reminder.message;

    return Scaffold(
        key: scaffoldkey,
        appBar: AppBar(
          leading: new GestureDetector(
            child: Icon(Icons.close, size: 30),
            onTap: () {
              Navigator.pop(context);
              remindersState.updateListView();
            },
          ),
          title: Text(appBarTitle, style: TextStyle(fontSize: 25)),
        ),
        body: ListView(children: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 50.0),

          Padding(
            padding: EdgeInsets.all(_minPadding),
            child: TextField(
              controller: reminderController,
              decoration: InputDecoration(
                  labelText: "Message",
                  hintText: "Write Message Here",
                  labelStyle: TextStyle(
                    fontSize: 20,
                    fontFamily: "Lato",
                    fontWeight: FontWeight.bold,
                  ),
                  hintStyle: TextStyle(
                      fontSize: 18,
                      fontFamily: "Lato",
                      fontStyle: FontStyle.italic,
                      color: Colors.grey)), //Input Decoration
            ), //TextField
          ),
          Padding(
            padding: EdgeInsets.all(_minPadding),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0)),
              padding: EdgeInsets.all(_minPadding / 2),
              color: Theme.of(context).primaryColor,
              textColor: Colors.white,
              elevation: 5.0,
              child: Text(
                "Save",
                style: buttonStyle,
                textAlign: TextAlign.center,
                textScaleFactor: 1.2,
              ),
              onPressed: () {
                setState(() {
                  _save();
                });
              },
            ), //RaisedButton
          ), //Padding

          Padding(
            padding: EdgeInsets.all(_minPadding),
            child: _isEditable()
                ? RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0)),
                    padding: EdgeInsets.all(_minPadding / 2),
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    elevation: 5.0,
                    child: Text(
                      "Delete",
                      style: buttonStyle,
                      textAlign: TextAlign.center,
                      textScaleFactor: 1.2,
                    ),
                    onPressed: () {
                      setState(() {
                        _delete();
                      });
                    },
                  ) //RaisedButton
                : Container(),
          ) //Padding
        ]) //ListView

        ); //Scaffold
  } //build()

  bool _isEditable() {
    if (this.appBarTitle == "Add Reminder")
      return false;
    else {
      return true;
    }
  }

  void updateReminder() {
    reminder.message = reminderController.text;
  }

  //check to make sure all of the fields are selected
  bool _checkNotNull() {
    bool res;
    if (reminderController.text.isEmpty) {
      utility.showSnackBar(scaffoldkey, 'Message cannot be empty');
      res = false;
    else {
      res = true;
    }
    return res;
  }

  String currentGroup = "";
  void _save() async {
    int result;
    String retString;

    Firestore _firestore = Firestore.instance;
    FirebaseAuth _auth = FirebaseAuth.instance;
    FirebaseUser currentUser = await _auth.currentUser();

    _firestore
        .collection("users")
        .document(currentUser.uid)
        .get()
        .then((value) {
      this.currentGroup = value.data["groupId"].toString();
      print("currentgroupid " + value.data["groupId"]);
    });
    if (_checkNotNull() == true) {
        test = await DBFuture().addReminder(this.currentGroup, reminder.message);
        reminder.id = ids + 1
        print(reminder.id);
      }

      remindersState.updateListView();

      Navigator.pop(context);

      if (result != 0) {
        utility.showAlertDialog(context, 'Status', 'Reminder saved successfully.');
      } else {
        utility.showAlertDialog(context, 'Status', 'Problem saving Reminder.');
      }
    }
  } //_save()

  //method to delete a reminder
  void _delete() {
    int result;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Are you sure, you want to delete this reminder?"),
            actions: <Widget>[
              RawMaterialButton(
                onPressed: () async {
                  await DBFuture().deleteReminder(currentGroup, reminder.id);
                  remindersState.updateListView();
                  Navigator.pop(context);
                  Navigator.pop(context);
                  utility.showSnackBar(
                      scaffoldkey, 'Reminder Deleted Successfully.');
                },
                child: Text("Yes"),
              ),
              RawMaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("No"),
              )
            ],
          );
        });
  }
}
