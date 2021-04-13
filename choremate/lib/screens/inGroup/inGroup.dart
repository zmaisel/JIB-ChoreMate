//import 'package:choremate/custom%20widgets/CustomWidget.dart';
import 'package:choremate/models/groupModel.dart';
import 'package:choremate/models/userModel.dart';
//import 'package:choremate/screens/createGroup/createGroup.dart';
import 'package:choremate/screens/groupDetails.dart';
import 'package:choremate/screens/root/root.dart';
import 'package:choremate/services/auth.dart';
//import 'package:choremate/services/dbFuture.dart';
//import 'package:choremate/services/dbStream.dart';
//import 'package:choremate/states/currentUser.dart';
import 'package:choremate/widgets/shadowContainer.dart';
import 'package:flutter/material.dart';
//import '../home_widget.dart';
import '../chores/todo.dart';
import 'package:choremate/screens/calendar/calendar2.dart';
import 'package:choremate/screens/reminders/reminders.dart';

class InGroup extends StatefulWidget {
  final UserModel userModel;
  final GroupModel groupModel;

  InGroup({this.userModel, this.groupModel});

  @override
  InGroupState createState() => InGroupState();
}

class InGroupState extends State<InGroup> {
  final key = new GlobalKey<ScaffoldState>();
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _signOut(BuildContext context) async {
    String _returnString = await Auth().signOut();
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
          height: 40,
        ),
        Padding(
            padding: const EdgeInsets.all(10.0),
            child: ShadowContainer(
                child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.person, color: blue),
                ),
                Text(widget.userModel.email,
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold))
              ],
            ))),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: ShadowContainer(
            child: Column(
              children: <Widget>[
                Text(widget.userModel.groupName,
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: RaisedButton(
                      child: Text("Show More"),
                      onPressed: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                GroupDetails(userModel: widget.userModel),
                          ),
                        );
                      },
                    )),
              ],
            ),
          ),
        ),
        // Padding(
        //   padding: const EdgeInsets.all(10.0),
        //   child: FloatingActionButton(
        //     tooltip: "Add Household",
        //     child: Icon(Icons.add),
        //     backgroundColor: green,
        //     onPressed: () => CreateGroup(userModel: widget.userModel),
        //   ),
        // ),
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 40.0),
        //   child: RaisedButton(
        //     child: Text("Copy Group Id"),
        //     onPressed: () => _copyGroupId(context),
        //     color: Theme.of(context).canvasColor,
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(20.0),
        //       side: BorderSide(
        //         color: Theme.of(context).secondaryHeaderColor,
        //         width: 2,
        //       ),
        //     ),
        //   ),
        // ),
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20),
        //   child: FlatButton(
        //     child: Text("Leave Group"),
        //     onPressed: () => _leaveGroup(context),
        //     color: Theme.of(context).canvasColor,
        //   ),
        // ),
        Padding(
          padding: const EdgeInsets.all(40.0),
          child: RaisedButton(
            child: Text("Sign Out"),
            onPressed: () => _signOut(context),
          ),
        ),
      ]),
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
            label: 'Reminders',
            backgroundColor: blue,
          )
        ],
      ),
    );
  }
}
