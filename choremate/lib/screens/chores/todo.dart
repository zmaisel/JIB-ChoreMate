import 'package:choremate/models/userModel.dart';
import 'package:choremate/screens/root/root.dart';
import 'package:choremate/services/dbFuture.dart';
import 'package:flutter/material.dart';
import 'package:choremate/screens/chores/newChore.dart';
import 'package:choremate/models/task.dart';
import 'package:choremate/custom widgets/CustomWidget.dart';
import 'package:choremate/utilities/theme_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:choremate/localizations.dart';
import 'package:choremate/utilities/utils.dart';
import 'package:choremate/screens/reminders/reminders.dart';

import 'package:choremate/screens/calendar/calendar2.dart';

class Todo extends StatefulWidget {
  final UserModel userModel;
  Todo({this.userModel});

  @override
  State<StatefulWidget> createState() {
    return TodoState();
  }
}

class TodoState extends State<Todo> {
  Utils utility = new Utils();
  List<Task> taskList;
  int count = 0;
  int index = 1;
  String _themeType;
  String dropdownValue = "My Chores";

  final homeScaffold = GlobalKey<ScaffoldState>();

  @override
  void initState() {
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
                case 2:
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          Calendar(userModel: widget.userModel),
                    ),
                    (route) => false,
                  );
                  break;
                case 3:
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          Reminders(userModel: widget.userModel),
                    ),
                    (route) => false,
                  );
                  break;
              }
            },
            fixedColor: Colors.black,
            items: [
              BottomNavigationBarItem(
                icon: new Icon(Icons.home),
                label: 'Home',
                backgroundColor: blue,
              ),
              BottomNavigationBarItem(
                icon: new Icon(Icons.cleaning_services),
                label: 'Chores',
                backgroundColor: blue,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today),
                label: 'Calendar',
                backgroundColor: blue,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications),
                label: 'Reminders',
                backgroundColor: blue,
              )
            ],
          ), //AppBar
          body: TabBarView(children: [
            new Container(
              padding: EdgeInsets.all(8.0),
              child: ListView(
                children: <Widget>[
                  DropdownButton(
                    value: dropdownValue,
                    icon: const Icon(Icons.arrow_drop_down_outlined),
                    underline: Container(height: 2, color: Colors.grey),
                    onChanged: (String newValue) {
                      setState(() {
                        dropdownValue = newValue;
                        updateListView();
                      });
                    },
                    items: <String>['My Chores', 'Household Chores']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: FutureBuilder(
                      future: DBFuture().determineChoreList(dropdownValue,
                          widget.userModel.groupId, widget.userModel.uid),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.data == null) {
                          return Text("Please select a Chore List to view");
                        } else {
                          if (snapshot.data.length < 1) {
                            return Text(
                              'No Chores Added',
                              style: TextStyle(fontSize: 15),
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
                                    //widget that shows the chores on the list
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
                                                    color: blue,
                                                    onPressed: null,
                                                  )
                                                : Container(),
                                        trailing: Icon(
                                          Icons.edit,
                                          color: blue,
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
                                                        .data[position]
                                                        .choreID);
                                                  },
                                                )
                                              : Container(),
                                          trailing: Container()
//
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
                navigateToTask(Task('', '', '', '', '', '', '', '', null),
                    "Add Chore", this);
              }), //FloatingActionButton
        ));
  } //build()

  void navigateToTask(Task task, String title, TodoState obj) async {
    bool result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => NewTask(task, title, obj, widget.userModel)),
    );
    //code above changes to screen where you can create a new chore
    updateListView();
  }

  //update the screen with the lastest chore list
  void updateListView() async {
    //calls function in DBFuture to determine whether it is the user
    //or the household list that the user wants to view
    //and queries the correct data accordingly
    List<Task> choreList = await DBFuture().determineChoreList(
        dropdownValue, widget.userModel.groupId, widget.userModel.uid);
    setState(() {
      this.taskList = choreList;
      this.count = choreList.length;
    });
  } //updateListView()

  //delete a chore from the database
  void delete(String choreID) async {
    //await databaseHelper.deleteTask(id);
    await DBFuture().deleteChore(widget.userModel.groupId, choreID);
    updateListView();
    //Navigator.pop(context);
    utility.showSnackBar(homeScaffold, 'Chore Deleted Successfully');
  }
}
