import 'dart:math';
import 'package:choremate/models/userModel.dart';
import 'package:flutter/material.dart';
import 'package:choremate/models/task.dart';
import 'package:choremate/screens/todo.dart';
import 'package:choremate/utilities/utils.dart';
import 'package:choremate/screens/calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:choremate/services/dbFuture.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:choremate/models/message.dart';
import 'package:choremate/screens/reminders.dart';

class new_message extends StatefulWidget {
  final String appBarTitle;
  final Message message;
  final UserModel currentUser;

  reminders_state remindersState;
  new_message(
      this.message, this.appBarTitle, this.remindersState, this.currentUser);
  bool _isEditable = false;

  @override
  State<StatefulWidget> createState() {
    return message_state(this.message, this.appBarTitle, this.remindersState);
  }
}

class message_state extends State<new_message> {
  reminders_state remindersState;
  String appBarTitle;
  Message message;
  List<Widget> icons;
  String dropdownValue;

  List<String> userList;

  message_state(this.message, this.appBarTitle, this.remindersState);

  bool marked = false;

  TextStyle titleStyle = new TextStyle(
    fontSize: 18,
    fontFamily: "Lato",
  );

  TextStyle buttonStyle =
      new TextStyle(fontSize: 18, fontFamily: "Lato", color: Colors.white);

  final scaffoldkey = GlobalKey<ScaffoldState>();
  Utils utility = new Utils();
  TextEditingController messageController = new TextEditingController();

  var _minPadding = 10.0;

  @override
  Widget build(BuildContext context) {
    messageController.text = message.message;
    getGroupMembers();

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
              child: Container(
                height: 2,
              )),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text("Remind:", style: titleStyle),
          ),
          Padding(
              padding: EdgeInsets.all(_minPadding),
              child: FutureBuilder(
                  future: DBFuture().getUserList(widget.currentUser.groupId),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.data == null) {
                      return Text("Loading");
                    }
                    return DropdownButton<String>(
                      value: dropdownValue,
                      icon: const Icon(Icons.arrow_drop_down_outlined),
                      underline: Container(height: 2, color: Colors.grey),
                      onChanged: (String newValue) {
                        setState(() {
                          dropdownValue = newValue;
                          message.sentTo = dropdownValue;
                        });
                      },
                      items: userList
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    );
                  })),
          Padding(
              padding: EdgeInsets.only(right: 50.0),
              child: Container(
                height: 2,
              )),
          Padding(
            padding: EdgeInsets.all(_minPadding),
            child: TextField(
              controller: messageController,
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
              onChanged: (value) {
                updateMessage();
              },
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

  void markedDone() {}

  bool _isEditable() {
    if (this.appBarTitle == "Add Reminder")
      return false;
    else {
      return true;
    }
  }

  void updateMessage() {
    message.message = messageController.text;
    //DBFuture().updateMessage(message.messageID, currentGroup);
  }

  //check to make sure all of the fields are selected
  bool _checkNotNull() {
    bool res;
    if (messageController.text.isEmpty) {
      utility.showSnackBar(scaffoldkey, 'Message cannot be empty');
      res = false;
    } else {
      res = true;
    }
    return res;
  }

  String currentGroup = "";
  String messageID = "";
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
      message =
          await DBFuture().addReminder(widget.currentUser.groupId, message);

      remindersState.updateListView();

      Navigator.pop(context);

      if (result != 0) {
        utility.showAlertDialog(
            context, 'Status', 'Reminder saved successfully.');
      } else {
        utility.showAlertDialog(context, 'Status', 'Problem saving message.');
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
                  await DBFuture().deleteReminder(
                      widget.currentUser.groupId, message.messageID);
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

  void getGroupMembers() async {
    userList = await DBFuture().getUserList(widget.currentUser.groupId);
  }
}
