import 'package:choremate/models/userModel.dart';
import 'package:choremate/screens/reminders/reminders.dart';
import 'package:choremate/screens/root/root.dart';
import 'package:choremate/screens/userData.dart';
import 'package:choremate/services/dbFuture.dart';
import 'package:flutter/material.dart';
import 'package:choremate/screens/chores/todo.dart';

import 'calendar/calendar2.dart';

class GroupDetails extends StatefulWidget {
  final UserModel userModel;
  //final GroupModel groupModel;

  GroupDetails({
    this.userModel,
  });

  @override
  GroupDetailsState createState() => GroupDetailsState();
}

class GroupDetailsState extends State<GroupDetails> {
  final key = new GlobalKey<ScaffoldState>();
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _leaveGroup(BuildContext context) async {
    String _returnString =
        await DBFuture().leaveGroup(widget.userModel.groupId, widget.userModel);
    if (_returnString == "success") {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => OurRoot(),
        ),
        (route) => false,
      );
    }
  }

  int index = 0;

  @override
  Widget build(BuildContext context) {
    Color green = const Color(0xFFa8e1a6);
    Color blue = const Color(0xFF5ac9fc);
    return Scaffold(
      appBar: AppBar(
        title: Text('ChoreMate'),
        backgroundColor: blue,
      ),
      body: ListView(children: <Widget>[
        SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(widget.userModel.groupName,
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Group ID: " + widget.userModel.groupId,
              style: TextStyle(fontSize: 16)),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height,
          child: FutureBuilder(
            future: DBFuture().getUserList(widget.userModel.groupId),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.data == null) {
                return Text("Loading");
              } else {
                if (snapshot.data.length < 1) {
                  return Center(
                    child: Text(
                      'Household has no members',
                      style: TextStyle(fontSize: 20),
                    ),
                  );
                }
                return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int position) {
                      return new GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserData(
                                      userModel: widget.userModel,
                                      position: position),
                                ));
                          },
                          child: Card(
                              margin: EdgeInsets.all(1.0),
                              elevation: 2.0,
                              child: ListTile(
                                  leading: Icon(Icons.person, color: blue),
                                  title: Text(snapshot.data[position]),
                                  trailing:
                                      Icon(Icons.arrow_forward_ios))) //Card
                          );
                    });
              }
            },
          ),
        ),
      ]),
      bottomSheet: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20),
        child: RaisedButton(
          child: Text("Leave Group"),
          onPressed: () => _leaveGroup(context),
          //color: green,
        ),
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
