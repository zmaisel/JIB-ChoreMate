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

import 'home_widget.dart';

class todo extends StatefulWidget {
  //final bool darkThemeEnabled;
  //todo(this.darkThemeEnabled);
  final UserModel userModel;
  todo({this.userModel});

  @override
  State<StatefulWidget> createState() {
    return todo_state();
  }
}

class todo_state extends State<todo> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  Utils utility = new Utils();
  List<Task> taskList;
  int count = 0;
  int index = 1;
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
    if (taskList == null) {
      taskList = List<Task>();
      updateListView();
    }

    return DefaultTabController(
        length: 2,
        child: Scaffold(
          key: homeScaffold,
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
            bottom: TabBar(tabs: [
              Tab(
                icon: Icon(Icons.format_list_numbered_rtl),
              ),
              Tab(
                icon: Icon(Icons.playlist_add_check),
              )
            ]),
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
                      builder: (context) => todo(userModel: widget.userModel),
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
          ), //AppBar
          body: TabBarView(children: [
            new Container(
              padding: EdgeInsets.all(8.0),
              child: ListView(
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: FutureBuilder(
                      future: DBFuture().getChoreList(widget.userModel.groupId),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.data == null) {
                          return Text("Loading");
                        } else {
                          if (snapshot.data.length < 1) {
                            return Center(
                              child: Text(
                                'No Chores Added',
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
                                        navigateToTask(snapshot.data[position],
                                            "Edit Chore", this);
                                    },
                                    child: Card(
                                      margin: EdgeInsets.all(1.0),
                                      elevation: 2.0,
                                      child: CustomWidget(
                                        title: snapshot.data[position].task,
                                        sub1: snapshot.data[position].date,
                                        sub2: snapshot.data[position].time,
                                        status: snapshot.data[position].status,
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
            ), //Container
            new Container(
              padding: EdgeInsets.all(8.0),
              child: ListView(
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: FutureBuilder(
                      future: DBFuture()
                          .getCompletedChoreList(widget.userModel.groupId),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.data == null) {
                          return Text("Loading");
                        } else {
                          if (snapshot.data.length < 1) {
                            return Center(
                              child: Text(
                                'No Chores Completed',
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
                                        navigateToTask(snapshot.data[position],
                                            "Edit Chore", this);
                                    },
                                    child: Card(
                                      margin: EdgeInsets.all(1.0),
                                      elevation: 2.0,
                                      child: CustomWidget(
                                          title: snapshot.data[position].task,
                                          sub1: snapshot.data[position].date,
                                          sub2: snapshot.data[position].time,
                                          status:
                                              snapshot.data[position].status,
                                          delete: snapshot
                                                      .data[position].status ==
                                                  "Chore Completed"
                                              ? IconButton(
                                                  icon: Icon(Icons.delete,
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                      size: 28),
                                                  onPressed: () {
                                                    delete(snapshot
                                                        .data[position].id);
                                                  },
                                                )
                                              : Container(),
                                          trailing: Container()
//                                    Icon(
//                                          Icons.edit,
//                                          color: Theme.of(context).primaryColor,
//                                          size: 28,
//                                        ),
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
            ), //Container
          ]),
          floatingActionButton: FloatingActionButton(
              tooltip: "Add Chore",
              child: Icon(Icons.add),
              backgroundColor: green,
              onPressed: () {
                navigateToTask(
                    Task('', '', '', '', '', Repeating.start, '', ''),
                    "Add Chore",
                    this);
              }), //FloatingActionButton
        ));
  } //build()

  void navigateToTask(Task task, String title, todo_state obj) async {
    //null ones are what we need to fix in order to make this work
    print(task.assignment);
    print(task.choreID);
    print(task.date);
    print(task.id); //null
    print(task.rpt); //null
    print(task.status);
    print(task.task);
    print(task.time);
    print(task.value); //null
    bool result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => new_task(task, title, obj)),
    );
    if (result == true) {
      updateListView();
    }
  }

  //update the screen with the lastest chore list
  void updateListView() async {
    //final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    //Firestore _firestore = Firestore.instance;
    String groupId = await DBFuture().getCurrentGroup();
    List<Task> choreList = await DBFuture().getChoreList(groupId);

    setState(() {
      this.taskList = choreList;
      this.count = choreList.length;
    });

    // dbFuture.then((database) {
    //   Future<List<Task>> taskListFuture = databaseHelper.getTaskList();
    //   taskListFuture.then((taskList) {
    //     setState(() {
    //       this.taskList = taskList;
    //       this.count = taskList.length;
    //     });
    //   });
    // });
  } //updateListView()

  //delete a chore from the database
  void delete(int id) async {
    await databaseHelper.deleteTask(id);
    updateListView();
    //Navigator.pop(context);
    utility.showSnackBar(homeScaffold, 'Chore Deleted Successfully');
  }
}
