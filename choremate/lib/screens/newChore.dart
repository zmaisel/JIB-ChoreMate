import 'package:choremate/models/choreModel.dart';
import 'package:flutter/material.dart';
import 'package:choremate/utilities/databaseHelper.dart';
//import 'package:choremate/models/task.dart';
import 'package:choremate/screens/todo.dart';
import 'package:choremate/utilities/utils.dart';
import 'package:choremate/screens/calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:choremate/services/dbFuture.dart';
import 'package:firebase_auth/firebase_auth.dart';

var globalDate = "Pick Date";

class new_task extends StatefulWidget {
  final String appBarTitle;
  final ChoreModel chore;
  todo_state todoState;
  new_task(this.chore, this.appBarTitle, this.todoState);
  bool _isEditable = false;

  @override
  State<StatefulWidget> createState() {
    return task_state(this.chore, this.appBarTitle, this.todoState);
  }
}

class task_state extends State<new_task> {
  todo_state todoState;
  String appBarTitle;
  ChoreModel chore;
  List<Widget> icons;
  task_state(this.chore, this.appBarTitle, this.todoState);

  bool marked = false;

  TextStyle titleStyle = new TextStyle(
    fontSize: 18,
    fontFamily: "Lato",
  );

  TextStyle buttonStyle =
      new TextStyle(fontSize: 18, fontFamily: "Lato", color: Colors.white);

  final scaffoldkey = GlobalKey<ScaffoldState>();

  //DatabaseHelper helper = DatabaseHelper();
  Utils utility = new Utils();
  TextEditingController taskController = new TextEditingController();
  TextEditingController assignmentController = new TextEditingController();
  TextEditingController groupController = new TextEditingController();

  var formattedDate = "Pick Date";
  var formattedTime = "Select Time";
  var _minPadding = 10.0;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay();

  @override
  Widget build(BuildContext context) {
    taskController.text = chore.name;
    assignmentController.text = chore.uid;
    groupController.text = chore.groupId;

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
              padding: EdgeInsets.all(_minPadding),
              child: TextField(
                controller: assignmentController,
                decoration: InputDecoration(
                    labelText: "Assign to",
                    hintText: "name",
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
              )),
          Padding(
              padding: EdgeInsets.all(_minPadding),
              child: TextField(
                controller: groupController,
                decoration: InputDecoration(
                    labelText: "Household",
                    hintText: "Household ID",
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
              )),
          ListTile(
            title: chore.dueDate.isEmpty
                ? Text(
                    "Pick Date",
                    style: titleStyle,
                  )
                : Text(chore.dueDate),
            subtitle: Text(""),
            trailing: Icon(Icons.calendar_today),
            onTap: () async {
              var pickedDate = await utility.selectDate(context, chore.dueDate);
              if (pickedDate != null && pickedDate.isNotEmpty)
                setState(() {
                  this.formattedDate = pickedDate.toString();
                  chore.dueDate = formattedDate;
                });
            },
          ), //DateListTile

          ListTile(
            title: chore.dueTime.isEmpty
                ? Text(
                    "Select Time",
                    style: titleStyle,
                  )
                : Text(chore.dueTime),
            subtitle: Text(""),
            trailing: Icon(Icons.access_time),
            onTap: () async {
              var pickedTime = await utility.selectTime(context);
              if (pickedTime != null && pickedTime.isNotEmpty)
                setState(() {
                  formattedTime = pickedTime;
                  chore.dueTime = formattedTime;
                });
            },
          ),
          // radio buttons for repeating feature of chore
          Padding(
              padding: EdgeInsets.only(right: 50.0),
              child: _isEditable()
                  ? Text(
                      "Current Repetition: " + chore.repeating,
                      style: titleStyle,
                    )
                  : Container(
                      height: 2,
                    )),
          ListTile(
            title: const Text('Daily'),
            leading: Radio(
              value: Repeating.daily,
              groupValue: chore.value,
              onChanged: (Repeating value) {
                setState(() {
                  chore.repeating = "Daily";
                  chore.value = value;
                });
              },
            ),
          ),
          ListTile(
            title: const Text('Weekly'),
            leading: Radio(
              value: Repeating.weekly,
              groupValue: chore.value,
              onChanged: (Repeating value) {
                setState(() {
                  chore.repeating = "Weekly";
                  chore.value = value;
                });
              },
            ),
          ),
          ListTile(
            title: const Text('Monthly'),
            leading: Radio(
              value: Repeating.monthly,
              groupValue: chore.value,
              onChanged: (Repeating value) {
                setState(() {
                  chore.repeating = "Monthly";
                  chore.value = value;
                });
              },
            ),
          ),
          ListTile(
            title: const Text('None'),
            leading: Radio(
              value: Repeating.none,
              groupValue: chore.value,
              onChanged: (Repeating value) {
                setState(() {
                  chore.repeating = "None";
                  chore.value = value;
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
    if (this.appBarTitle == "Add Chore")
      return false;
    else {
      return true;
    }
  }

  void updateTask() {
    task.task = taskController.text;
    task.assignment = assignmentController.text;
    //DBFuture().updateChore(task.choreID, currentGroup, task.task, task.date, task.time, task.status, task.rpt, task.assignment);
  }

  //check to make sure all of the fields are selected
  bool _checkNotNull() {
    bool res;
    if (taskController.text.isEmpty) {
      utility.showSnackBar(scaffoldkey, 'Task cannot be empty');
      res = false;
    } else if (chore.dueDate.isEmpty) {
      utility.showSnackBar(scaffoldkey, 'Please select the Date');
      res = false;
    } else if (chore.dueTime.isEmpty) {
      utility.showSnackBar(scaffoldkey, 'Please select the Time');
      res = false;
    } else if (chore.uid.isEmpty) {
      utility.showSnackBar(scaffoldkey, 'Please assign the chore to a user');
    } else if (chore.repeating.isEmpty) {
      utility.showSnackBar(scaffoldkey, 'Please select a repeating option');
    } else {
      res = true;
    }
    return res;
  }

  //Save data
  String currentGroup = "";
  String choreID = "";
  void _save() async {
    String result;
    if (_isEditable()) {
      if (marked) {
        chore.status = "Task Completed";
      } else
        chore.status = "";
    }
    //task.task = taskController.text;
    //task.date = formattedDate;
    Firestore _firestore = Firestore.instance;
    FirebaseAuth _auth = FirebaseAuth.instance;
    FirebaseUser currentUser = await _auth.currentUser();

    _firestore.collection("users").document(currentUser.uid).get().then((value) {
      this.currentGroup = value.data["groupId"].toString();
      print("currentgroupid " + value.data["groupId"]);
    });

    if (_checkNotNull() == true) {
      if (chore.choreId != null) {
        //Update Operation
        print("updated");
        
        print(task.choreID);
        result = await helper.updateTask(task);
        List<Task> listChores = await helper.getTaskList();
        listChores.forEach((element) {print(element.task); });
        //String value = await DBFuture().updateChore(this.choreID, currentGroup, task.task, task.date, task.time, task.status, task.rpt, task.assignment);

        print("updated2");
        
      } else {
        //Insert Operation
        result = await helper.insertTask(task);

        task.choreID = await DBFuture().addChore(this.currentGroup, task.task, task.date, task.time, task.status, task.rpt, task.assignment);
        print("choreID: " + task.choreID);
        task.id = 1;
        // _firestore.collection("groups").document(currentGroup).updateData({
        //   "chores": "yes"
        // }).then((value) => {
        //   _firestore.collection("groups").document(currentGroup).collection("Chores")
        // });
        

        //result = await DBFuture.updateTask(task);
      }

      todoState.updateListView();

      Navigator.pop(context);

      if (result == "success") {
        utility.showAlertDialog(context, 'Status', 'Chore saved successfully.');
      } else {
        utility.showAlertDialog(context, 'Status', 'Problem saving task.');
      }
    }
  } //_save()

  void _delete() {
    String result;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Are you sure, you want to delete this chore?"),
            actions: <Widget>[
              RawMaterialButton(
                onPressed: () async {
                  await DBFuture().deleteChore(chore.groupId, chore);
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
} //class task_state
