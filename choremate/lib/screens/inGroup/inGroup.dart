import 'package:choremate/models/groupModel.dart';
import 'package:choremate/models/userModel.dart';
import 'package:choremate/screens/createGroup/createGroup.dart';
import 'package:choremate/screens/root/root.dart';
import 'package:choremate/services/auth.dart';
import 'package:choremate/services/dbFuture.dart';
//import 'package:choremate/states/currentUser.dart';
import 'package:choremate/widgets/shadowContainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../home_widget.dart';
import '../todo.dart';

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

  void _leaveGroup(BuildContext context) async {
    GroupModel group = Provider.of<GroupModel>(context, listen: false);
    //UserModel user = Provider.of<UserModel>(context, listen: false);
    //print(group);
    String _returnString =
        await DBFuture().leaveGroup(group.id, widget.userModel);
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

  void _copyGroupId(BuildContext context) {
    GroupModel group = Provider.of<GroupModel>(context, listen: false);
    Clipboard.setData(ClipboardData(text: group.id));
    key.currentState.showSnackBar(SnackBar(
      content: Text("Copied!"),
    ));
  }

  // void _goToBookHistory() {
  //   GroupModel group = Provider.of<GroupModel>(context, listen: false);
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => BookHistory(
  //         groupId: group.id,
  //       ),
  //     ),
  //   );
  // }
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
            child: Column(
              children: <Widget>[
                Text(widget.userModel.groupName,
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: RaisedButton(
                    child: Text("Show More"),
                    onPressed: () => OurRoot(),
                  ),
                )
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: FloatingActionButton(
            tooltip: "Add Household",
            child: Icon(Icons.add),
            backgroundColor: green,
            onPressed: () => CreateGroup(userModel: widget.userModel),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: RaisedButton(
            child: Text("Copy Group Id"),
            onPressed: () => _copyGroupId(context),
            color: Theme.of(context).canvasColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
              side: BorderSide(
                color: Theme.of(context).secondaryHeaderColor,
                width: 2,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20),
          child: FlatButton(
            child: Text("Leave Group"),
            onPressed: () => _leaveGroup(context),
            color: Theme.of(context).canvasColor,
          ),
        ),
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OurRoot(),
                ),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => todo(),
                ),
              );
              break;
            case 2:
              Navigator.of(context).pushNamed('/Calendar');
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
      ),
    );
  }
}
