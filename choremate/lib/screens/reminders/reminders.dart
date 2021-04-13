import 'package:choremate/models/userModel.dart';
import 'package:choremate/screens/root/root.dart';
import 'package:choremate/services/dbFuture.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:choremate/utilities/theme_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:choremate/localizations.dart';
import 'package:choremate/utilities/utils.dart';
import 'package:choremate/models/message.dart';
import 'package:choremate/screens/reminders/newReminder.dart';
import 'package:choremate/screens/chores/todo.dart';

import 'package:choremate/screens/calendar/calendar2.dart';

class Reminders extends StatefulWidget {
  //final bool darkThemeEnabled;
  //reminders(this.darkThemeEnabled);
  final UserModel userModel;
  Reminders({this.userModel});

  @override
  State<StatefulWidget> createState() {
    return RemindersState();
  }
}

class RemindersState extends State<Reminders> {
  //DatabaseHelper databaseHelper = DatabaseHelper();
  Utils utility = new Utils();
  List<Message> messageList;
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
    if (messageList == null) {
      messageList = List<Message>();
      updateListView();
    }

    return Scaffold(
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
                  builder: (context) => Todo(userModel: widget.userModel),
                ),
                (route) => false,
              );
              break;
            case 2:
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => Calendar(userModel: widget.userModel),
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
      ),
      body: ListView(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height,
            child: FutureBuilder(
              future: DBFuture().getReminderList(
                  widget.userModel.groupId, widget.userModel.uid),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.data == null) {
                  return Text("Loading");
                } else {
                  if (snapshot.data.length < 1) {
                    return Center(
                      child: Text(
                        'No Reminders Added',
                        style: TextStyle(fontSize: 20),
                      ),
                    );
                  }
                  return ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int position) {
                        return new GestureDetector(
                            onTap: () {
                              navigateToMessage(snapshot.data[position],
                                  "Edit Reminder", this);
                            },
                            child: Card(
                              margin: EdgeInsets.all(1.0),
                              elevation: 2.0,
                              child: ListTile(
                                title: Text(snapshot.data[position].message),
                                trailing: Icon(
                                  Icons.edit,
                                  color: Theme.of(context).primaryColor,
                                  size: 28,
                                ),
                              ),
                            ));
                      });
                }
              },
            ),
          )
        ],
      ),

      floatingActionButton: FloatingActionButton(
          tooltip: "Add Reminder",
          child: Icon(Icons.add),
          backgroundColor: green,
          onPressed: () {
            navigateToMessage(Message('', '', '', ''), "Add Reminder", this);
          }), //FloatingActionButton
    );
  } //build()

  void navigateToMessage(
      Message message, String title, RemindersState obj) async {
    //null ones are what we need to fix in order to make this work

    print(message.messageID);
    print(message.message);
    bool result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              new_message(message, title, obj, widget.userModel)),
    );
    if (result == true) {
      updateListView();
    }
  }

  //update the screen with the lastest reminder list
  void updateListView() async {
    //Firestore _firestore = Firestore.instance;
    //String groupId = await DBFuture().getCurrentGroup();
    List<Message> reminderList = await DBFuture()
        .getReminderList(widget.userModel.groupId, widget.userModel.uid);

    setState(() {
      this.messageList = reminderList;
      this.count = reminderList.length;
    });
  } //updateListView()
}
