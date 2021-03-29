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

var globalDate = "Pick Date";

class new_task extends StatefulWidget {
  final String appBarTitle;
  final Task task;
  final UserModel currentUser;
  todo_state todoState;
  new_task(this.task, this.appBarTitle, this.todoState, this.currentUser);
  bool _isEditable = false;

  @override
  State<StatefulWidget> createState() {
    return task_state(this.task, this.appBarTitle, this.todoState);
  }
}

class task_state extends State<new_task> {
  todo_state todoState;
  String appBarTitle;
  Task task;
  List<Widget> icons;
  task_state(this.task, this.appBarTitle, this.todoState);

  bool marked = false;

  TextStyle titleStyle = new TextStyle(
    fontSize: 18,
    fontFamily: "Lato",
  );

  TextStyle buttonStyle =
      new TextStyle(fontSize: 18, fontFamily: "Lato", color: Colors.white);

  final scaffoldkey = GlobalKey<ScaffoldState>();

  Utils utility = new Utils();
  TextEditingController taskController = new TextEditingController();
  TextEditingController assignmentController = new TextEditingController();

  var formattedDate = "Pick Date";
  var formattedTime = "Select Time";
  var _minPadding = 10.0;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay();
  List<String> userList;

  String dropdownValue;

  @override
  Widget build(BuildContext context) {
    Color green = const Color(0xFFa8e1a6);
    Color blue = const Color(0xFF5ac9fc);
    getGroupMembers();
    taskController.text = task.task;
    //dropdownValue = userList.first;

    return Scaffold(
        key: scaffoldkey,
        appBar: AppBar(
          leading: new GestureDetector(
            child: Icon(Icons.close, size: 30),
            onTap: () {
              Navigator.pop(context);
              todoState.updateListView();
            },
          ),
          title: Text(appBarTitle, style: TextStyle(fontSize: 25)),
          backgroundColor: blue,
        ),
        body: ListView(children: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 50.0),
              child: _isEditable()
                  ? CheckboxListTile(
                      title: Text("Mark as Done", style: titleStyle),
                      value: marked,
                      onChanged: (bool value) {
                        setState(() {
                          marked = value;
                        });
                      }) //CheckboxListTile
                  : Container(
                      height: 2,
                    )),

          Padding(
            padding: EdgeInsets.all(_minPadding),
            child: TextField(
              controller: taskController,
              decoration: InputDecoration(
                  labelText: "Chore",
                  hintText: "E.g.  Vacuum",
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
                updateTask();
              },
            ), //TextField
          ),
          // text field to assign chore to a user //Padding
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text("Assign to:", style: titleStyle),
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
                          task.assignment = newValue;
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
          ListTile(
            title: task.date.isEmpty
                ? Text(
                    "Pick Date",
                    style: titleStyle,
                  )
                : Text(task.date),
            subtitle: Text(""),
            trailing: Icon(Icons.calendar_today),
            onTap: () async {
              var pickedDate = await utility.selectDate(context, task.date);
              if (pickedDate != null && pickedDate.isNotEmpty)
                setState(() {
                  this.formattedDate = pickedDate.toString();
                  task.date = formattedDate;
                });
            },
          ), //DateListTile

          ListTile(
            title: task.time.isEmpty
                ? Text(
                    "Select Time",
                    style: titleStyle,
                  )
                : Text(task.time),
            subtitle: Text(""),
            trailing: Icon(Icons.access_time),
            onTap: () async {
              var pickedTime = await utility.selectTime(context);
              if (pickedTime != null && pickedTime.isNotEmpty)
                setState(() {
                  formattedTime = pickedTime;
                  task.time = formattedTime;
                });
            },
          ),
          // radio buttons for repeating feature of chore
          Padding(
              padding: EdgeInsets.only(right: 50.0),
              child: _isEditable()
                  ? Text(
                      "Current Repetition: " + task.rpt,
                      style: titleStyle,
                    )
                  : Container(
                      height: 2,
                    )),
          ListTile(
            title: const Text('Daily'),
            leading: Radio(
              value: Repeating.daily,
              groupValue: task.value,
              onChanged: (Repeating value) {
                setState(() {
                  task.rpt = "Daily";
                  task.value = value;
                });
              },
            ),
          ),
          ListTile(
            title: const Text('Weekly'),
            leading: Radio(
              value: Repeating.weekly,
              groupValue: task.value,
              onChanged: (Repeating value) {
                setState(() {
                  task.rpt = "Weekly";
                  task.value = value;
                });
              },
            ),
          ),
          ListTile(
            title: const Text('Monthly'),
            leading: Radio(
              value: Repeating.monthly,
              groupValue: task.value,
              onChanged: (Repeating value) {
                setState(() {
                  task.rpt = "Monthly";
                  task.value = value;
                });
              },
            ),
          ),
          ListTile(
            title: const Text('None'),
            leading: Radio(
              value: Repeating.none,
              groupValue: task.value,
              onChanged: (Repeating value) {
                setState(() {
                  task.rpt = "None";
                  task.value = value;
                });
              },
            ),
          ), //TimeListTile
          Padding(
            padding: EdgeInsets.all(_minPadding),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0)),
              padding: EdgeInsets.all(_minPadding / 2),
              color: blue,
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
    if (this.appBarTitle == "Add Chore")
      return false;
    else {
      return true;
    }
  }

  void updateTask() {
    task.task = taskController.text;
  }

  //check to make sure all of the fields are selected
  bool _checkNotNull() {
    bool res;
    if (taskController.text.isEmpty) {
      utility.showSnackBar(scaffoldkey, 'Task cannot be empty');
      res = false;
    } else if (task.date.isEmpty) {
      utility.showSnackBar(scaffoldkey, 'Please select the Date');
      res = false;
    } else if (task.time.isEmpty) {
      utility.showSnackBar(scaffoldkey, 'Please select the Time');
      res = false;
    } else if (task.rpt.isEmpty) {
      utility.showSnackBar(scaffoldkey, 'Please select a repeating option');
    } else {
      res = true;
    }
    return res;
  }

  String currentGroup = "";
  String choreID = "";
  _save() async {
    int result;
    String retString;

    if (_isEditable()) {
      if (marked) {
        task.status = "Task Completed";
        //print("when completing, task id:" + task.choreID);
        //choreID user is null here which is why it doesn't delete it from user's chore list
        //same problem we had before but idk how i fixed it ://
        //ok it works when youre in the tab household chores
        //but not in the tab my chores
        //print(task.choreIDUser);
        DBFuture().completeChore(
            task, widget.currentUser.groupId, widget.currentUser.uid);
      } else {
        task.status = "";
        retString =
            await DBFuture().updateChore(widget.currentUser.groupId, task);
      }
    } else if (_checkNotNull() == true) {
      task = await DBFuture().addChore(task, widget.currentUser.groupId,
          widget.currentUser.fullName, widget.currentUser.uid);
      //print("assignment UID" + task.assignmentUID);
      //print("chore ID user: " + task.choreIDUser);
      //print("choreID here in newchore code: " + task.choreID);

      //print(task.id);
    }

    todoState.updateListView();

    Navigator.pop(context);

    if (result != 0) {
      utility.showAlertDialog(context, 'Status', 'Chore saved successfully.');
    } else {
      utility.showAlertDialog(context, 'Status', 'Problem saving task.');
    }
  } //_save()

  //method to delete a chore
  void _delete() {
    int result;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Are you sure, you want to delete this chore?"),
            actions: <Widget>[
              RawMaterialButton(
                onPressed: () async {
                  //print(task.choreID);
                  await DBFuture()
                      .deleteChore(widget.currentUser.groupId, task.choreID);
                  todoState.updateListView();
                  Navigator.pop(context);
                  Navigator.pop(context);
                  utility.showSnackBar(
                      scaffoldkey, 'Chore Deleted Successfully.');
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
} //class task_state
