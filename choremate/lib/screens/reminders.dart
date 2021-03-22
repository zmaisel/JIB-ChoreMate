import 'package:choremate/models/userModel.dart';
import 'package:choremate/screens/root/root.dart';
import 'package:choremate/services/dbFuture.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:choremate/screens/newChore.dart';
import 'dart:async';
import 'package:choremate/models/task.dart';
import 'package:choremate/utilities/databaseHelper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:choremate/custom widgets/CustomWidget.dart';
import 'package:choremate/utilities/theme_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:choremate/localizations.dart';
import 'package:choremate/utilities/utils.dart';
import 'package:choremate/screens/calendar.dart';
import 'package:choremate/screens/todo.dart';
import 'home_widget.dart';
import 'package:choremate/screens/newReminder.dart';

class reminders extends StatefulWidget {
  //final bool darkThemeEnabled;
  //reminders(this.darkThemeEnabled);
  final UserModel userModel;
  reminders({this.userModel});

  @override
  State<StatefulWidget> createState() {
    return reminders_state();
  }
}

class reminders_state extends State<reminders> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  Utils utility = new Utils();
  List<Reminder> reminderList;
  int count = 0;
  int index = 3;
  String _themeType;
  final homeScaffold = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // if (!widget.darkThemeEnabled) {
    //   _themeType = 'Light Theme';
    // } else {
    //   _themeType = 'Dark Theme';
    // }
    super.initState();
  }

  _setPref(bool res) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkTheme', res);
  }

  @override
  Widget build(BuildContext context) {
    Color green = const Color(0xFFa8e1a6);
    Color blue = const Color(0xFF5ac9fc);
    if (reminderList == null) {
      reminderList = List<Reminder>();
      updateListView();
    }

    return Scaffold(
          appBar: AppBar(
            title: Text('ChoreMate'
                //AppLocalizations.of(context).title(),
                //style: TextStyle(fontSize: 25),
                ),
            backgroundColor: blue,
            actions: <Widget>[
              PopupMenuButton<bool>(
                onSelected: (res) {
                  bloc.changeTheme(res);
                  _setPref(res);
                  setState(() {
                    if (_themeType == 'Dark Theme') {
                      _themeType = 'Light Theme';
                    } else {
                      _themeType = 'Dark Theme';
                    }
                  });
                },
                itemBuilder: (context) {
                  return <PopupMenuEntry<bool>>[
                    PopupMenuItem<bool>(
                      //value: !widget.darkThemeEnabled,
                      child: Text(_themeType),
                    )
                  ];
                },
              )
            ],
          ),
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
                      builder: (context) => reminders(userModel: widget.userModel),
                    ),
                    (route) => false,
                  );
                  break;
                case 2:
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          calendar(userModel: widget.userModel),
                    ),
                    (route) => false,
                  );
                  break;
                case 3:
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => case 3:
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => reminders(userModel: widget.userModel),
                    ),
                    (route) => false,
                  );
                  break;
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
                title: Text('Reminders'),
                backgroundColor: blue,
              )
            ],
          ), //AppBar
          body: ListView(child:
            new Container(
              padding: EdgeInsets.all(8.0),
              child: ListView(
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: FutureBuilder(
                      future: DBFuture().getReminderList(widget.userModel.groupId),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.data == null) {
                          return Text("Loading");
                        } else {
                          if (snapshot.data.length < 1) {
                            return Center(
                              child: Text(
                                'No Reminders',
                                style: TextStyle(fontSize: 20),
                              ),
                            );
                          }
                          return ListView.builder(
                              itemCount: snapshot.data.length,
                              itemBuilder:
                                  (BuildContext context, int position) {
                                return new GestureDetector(
                                    onTap: () {
                                      if (snapshot.data[position].status !=
                                          "Chore Completed")
                                        navigateToReminder(snapshot.data[position],
                                            "Edit Chore", this);
                                    },
                                    child: Card(
                                      margin: EdgeInsets.all(1.0),
                                      elevation: 2.0,
                                      child: CustomWidget(
                                        title: snapshot.data[position].message,
                                        delete:
                                            snapshot.data[position].status ==
                                                    "Chore Completed"
                                                ? IconButton(
                                                    icon: Icon(Icons.delete),
                                                    onPressed: null,
                                                  )
                                                : Container(),
                                        trailing: Icon(
                                          Icons.edit,
                                          color: Theme.of(context).primaryColor,
                                          size: 28,
                                        ),
                                      ),
                                    ) //Card
                                    );
                              });
                        }
                      },
                    ),
                  )
                ],
              ),
            ), 
          ]),
          floatingActionButton: FloatingActionButton(
              tooltip: "Add Reminder",
              child: Icon(Icons.add),
              backgroundColor: green,
              onPressed: () {
                navigateToReminder(
                    Reminder('', '', '', '', '', Repeating.start, '', ''),
                    "Add Reminder",
                    this);
              }), //FloatingActionButton
        ));
  } //build()

  void navigateToReminder(Reminder reminder, String title, reminders_state obj) async {
    //null ones are what we need to fix in order to make this work
    print(reminder.id);
    bool result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => new_reminder(reminder, title, obj)),
    );
    if (result == true) {
      updateListView();
    }
  }

  //update the screen with the lastest reminder list
  void updateListView() async {
    //final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    //Firestore _firestore = Firestore.instance;
    String groupId = await DBFuture().getCurrentGroup();
    List<Reminder> reminderList = await DBFuture().getReminderList(groupId);

    setState(() {
      this.reminderList = reminderList;
      this.count = reminderList.length;
    });
  } //updateListView()

  //delete a reminder from the database
  void delete(int id) async {
    await databaseHelper.deleteReminder(id);
    updateListView();
    //Navigator.pop(context);
    utility.showSnackBar(homeScaffold, 'Reminder Deleted Successfully');
  }
}