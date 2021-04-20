import 'package:choremate/models/userModel.dart';
import 'package:choremate/screens/reminders/reminders.dart';
import 'package:choremate/screens/root/root.dart';
import 'package:choremate/services/dbFuture.dart';
import 'package:flutter/material.dart';
import 'package:choremate/screens/chores/todo.dart';
import 'package:choremate/models/task.dart';

import 'package:choremate/screens/calendar/calendar2.dart';

class UserData extends StatefulWidget {
  final UserModel userModel;
  final int position;
  //final GroupModel groupModel;

  UserData({
    this.userModel,
    this.position,
  });

  @override
  UserDataState createState() => UserDataState();
}

class UserDataState extends State<UserData> {
  final key = new GlobalKey<ScaffoldState>();
  String userID;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<String> uid() async {
    var uidList = await DBFuture().getUIDList(widget.userModel.groupId);
    userID = uidList.elementAt(widget.position);
    return uidList.elementAt(widget.position);
  }

  Future<String> numIncompleteChores() async {
    String userID = await uid();
    List<Task> incompleteChores =
        await DBFuture().getUserChoreList(userID, widget.userModel.groupId);
    if (incompleteChores == null) {
      return "0";
    }
    return incompleteChores.length.toString();
  }

  Future<String> numCompleteChores() async {
    String userID = await uid();

    List<Task> completeChores =
        await DBFuture().getUserCompletedList(userID, widget.userModel.groupId);

    if (completeChores == null) {
      return "0";
    }
    return completeChores.length.toString();
  }

  Future<List<String>> userData() async {
    List<String> userData = List();
    String incompleteChores = await numIncompleteChores();
    userData.add("Incomplete Chores: " + incompleteChores);
    String completeChores = await numCompleteChores();
    userData.add("Completed Chores: " + completeChores);
    String percentageChores = ((int.parse(completeChores) /
                (int.parse(incompleteChores) + int.parse(completeChores))) *
            100)
        .toInt()
        .toString();
    userData.add("Percentage Completed: " + percentageChores + "%");
    return userData;
  }

  int index = 0;

  Widget setupIncompleteChores() {
    return Container(
        height: 300.0, // Change as per your requirement
        width: 300.0, // Change as per your requirement
        child: FutureBuilder(
            future:
                DBFuture().getUserChoreList(userID, widget.userModel.groupId),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.data == null) {
                return Text("Loading");
              }
              return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(snapshot.data[index].task),
                  );
                },
              );
            }));
  }

  Widget setupCompleteChores() {
    return Container(
        height: 300.0, // Change as per your requirement
        width: 300.0, // Change as per your requirement
        child: FutureBuilder(
            future: DBFuture()
                .getUserCompletedList(userID, widget.userModel.groupId),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.data == null) {
                return Text("Loading");
              }
              return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(snapshot.data[index].task),
                  );
                },
              );
            }));
  }

  @override
  Widget build(BuildContext context) {
    Color green = const Color(0xFFa8e1a6);
    Color blue = const Color(0xFF5ac9fc);

    return Scaffold(
      appBar: AppBar(
        title: Text('ChoreMate'),
        backgroundColor: blue,
      ),
      body: ListView(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height,
            child: FutureBuilder(
                future: userData(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.data == null) {
                    return Text("Loading");
                  }
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Incomplete Chores"),
                                content: setupIncompleteChores(),
                              );
                            },
                          );
                        },
                        child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Container(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(15, 25, 15, 25),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 5),
                                      child: Icon(
                                        Icons.cancel_outlined,
                                        color: Colors.red,
                                        size: 25,
                                      ),
                                    ),
                                    (Text(snapshot.data[0],
                                        style: TextStyle(fontSize: 22))),
                                  ],
                                ),
                              ),
                              decoration: BoxDecoration(
                                  border: Border.all(color: blue, width: 4),
                                  borderRadius: BorderRadius.circular(12)),
                            )),
                      ),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Complete Chores"),
                                content: setupCompleteChores(),
                              );
                            },
                          );
                        },
                        child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Container(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(15, 25, 15, 25),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 5),
                                      child: Icon(
                                        Icons.check_circle_outline,
                                        color: green,
                                        size: 25,
                                      ),
                                    ),
                                    (Text(snapshot.data[1],
                                        style: TextStyle(fontSize: 22))),
                                  ],
                                ),
                              ),
                              decoration: BoxDecoration(
                                  border: Border.all(color: blue, width: 4),
                                  borderRadius: BorderRadius.circular(12)),
                            )),
                      ),
                      Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Container(
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(15, 25, 15, 25),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 5.0),
                                    child: Icon(
                                        Icons.pie_chart_outline_outlined,
                                        color: blue,
                                        size: 25),
                                  ),
                                  (Text(snapshot.data[2],
                                      style: TextStyle(fontSize: 20))),
                                ],
                              ),
                            ),
                            decoration: BoxDecoration(
                                border: Border.all(color: blue, width: 4),
                                borderRadius: BorderRadius.circular(12)),
                          ))
                    ],
                  );
                }),
          ),
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
            case 3:
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => Reminders(userModel: widget.userModel),
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
            label: 'Notifcations',
            backgroundColor: blue,
          )
        ],
      ),
    );
  }
}
