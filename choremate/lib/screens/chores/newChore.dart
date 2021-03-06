import 'package:choremate/models/userModel.dart';
import 'package:flutter/material.dart';
import 'package:choremate/models/task.dart';
import 'package:choremate/screens/chores/todo.dart';
import 'package:choremate/utilities/utils.dart';
import 'package:choremate/services/dbFuture.dart';
import 'package:intl/intl.dart';

var globalDate = "Pick Date";

class NewTask extends StatefulWidget {
  final String appBarTitle;
  final Task task;
  final UserModel currentUser;
  TodoState todoState;
  NewTask(this.task, this.appBarTitle, this.todoState, this.currentUser);
  //bool _isEditable = false;

  @override
  State<StatefulWidget> createState() {
    return TaskState(this.task, this.appBarTitle, this.todoState);
  }
}

class TaskState extends State<NewTask> {
  TodoState todoState;
  String appBarTitle;
  Task task;
  List<Widget> icons;
  TaskState(this.task, this.appBarTitle, this.todoState);

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

  var formattedDate = "Pick Date";
  var formattedTime = "Select Time";
  var _minPadding = 10.0;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay();
  List<String> userList;

  String dropdownValue;

  @override
  Widget build(BuildContext context) {
    Color blue = const Color(0xFF5ac9fc);
    getGroupMembers();
    taskController.text = task.task;
    if (task.assignment != '') {
      dropdownValue = task.assignment;
      print("true?");
    }

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
            //text field to enter name of chore
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
              //drop down menu to assign chore to a user
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
                          print("task assignment" + task.assignment);
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
            //date widget
            title: task.date.isEmpty
                ? Text(
                    "Pick Date",
                    style: titleStyle,
                  )
                : Text(task.date),
            subtitle: Text(""),
            trailing: Icon(Icons.calendar_today),
            onTap: () async {
              var pickedDate = await selectDate(context, task.date);
              if (pickedDate != null && pickedDate.isNotEmpty)
                setState(() {
                  this.formattedDate = pickedDate.toString();
                  task.date = formattedDate;
                });
            },
          ), //DateListTile

          ListTile(
            //time widget
            title: task.time.isEmpty
                ? Text(
                    "Select Time",
                    style: titleStyle,
                  )
                : Text(task.time),
            subtitle: Text(""),
            trailing: Icon(Icons.access_time),
            onTap: () async {
              var pickedTime = await selectTime(context);
              if (pickedTime != null && pickedTime.isNotEmpty)
                setState(() {
                  formattedTime = pickedTime;
                  task.time = formattedTime;
                });
            },
          ),
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
            //ability to mark as done and delete
            padding: EdgeInsets.all(_minPadding),
            child: _isEditable()
                ? RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0)),
                    padding: EdgeInsets.all(_minPadding / 2),
                    color: blue,
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
    } else {
      res = true;
    }
    return res;
  }

  String currentGroup = "";
  String choreID = "";
  void _save() async {
    int result;
    String retString;

    if (_isEditable()) {
      if (marked) {
        //check if the box is marked to complete the chore, if it is,
        // make the changes in the backend
        task.status = "Task Completed";

        DBFuture().completeChore(
            task, widget.currentUser.groupId, widget.currentUser.uid);
      } else {
        task.status = "";
        retString =
            await DBFuture().updateChore(widget.currentUser.groupId, task);
      }
    } else if (_checkNotNull() == true) {
      //otherwise, add the chore because it is new
      task = await DBFuture().addChore(task, widget.currentUser.groupId,
          widget.currentUser.fullName, widget.currentUser.uid);
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

  //function for selecting date
  Future<String> selectDate(BuildContext context, String date) async {
    final DateTime picked = await showDatePicker(
        context: context,
        firstDate: DateTime.now(),
        initialDate: date.isEmpty
            ? DateTime.now()
            : new DateFormat("MMMM d, yyyy 'at' h:mma"),
        lastDate: DateTime(2025));
    if (picked != null) {
      task.dateTime = picked;
      return formatDate(picked);
    }

    return "";
  }

  //function for selecting time
  Future<String> selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      //initialTime: task.time.isEmpty ? _initialTime : new TimeOfDay().parse(task.time),
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child,
        );
      },
    );
    if (picked != null) {
      task.dateTime = task.dateTime.add(Duration(days: 0, hours: picked.hour));
      return timeFormat(picked);
    }

    return "";
  }

  //formate the time
  String timeFormat(TimeOfDay picked) {
    var hour = 00;
    var Time = "PM";
    if (picked.hour >= 12) {
      Time = "PM";
      if (picked.hour > 12) {
        hour = picked.hour - 12;
      } else if (picked.hour == 00) {
        hour = 12;
      } else {
        hour = picked.hour;
      }
    } else {
      Time = "AM";
      if (picked.hour == 00) {
        hour = 12;
      } else {
        hour = picked.hour;
      }
    }
    var h, m;
    if (hour % 100 < 10) {
      h = "0" + hour.toString();
    } else {
      h = hour.toString();
    }

    int minute = picked.minute;
    if (minute % 100 < 10)
      m = "0" + minute.toString();
    else
      m = minute.toString();

    return h + ":" + m + " " + Time;
  }

  //format the date
  String formatDate(DateTime selectedDate) =>
      new DateFormat("d MMM, y").format(selectedDate);
}
//class task_state
