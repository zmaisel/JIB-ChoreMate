import 'package:choremate/models/userModel.dart';
import 'package:choremate/screens/createGroup/createGroup.dart';
import 'package:choremate/screens/joinGroup/joinGroup.dart';
import 'package:choremate/screens/root/root.dart';
import 'package:choremate/services/auth.dart';
//import 'package:choremate/widgets/shadowContainer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//import '../home_widget.dart';
import '../todo.dart';
import 'package:choremate/screens/calendar.dart';
import 'package:choremate/screens/reminders.dart';

class NoGroup extends StatefulWidget {
  @override
  NoGroupState createState() => NoGroupState();
}

class NoGroupState extends State<NoGroup> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    UserModel _currentUser = Provider.of<UserModel>(context);
    void _goToJoin(BuildContext context) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JoinGroup(
            userModel: _currentUser,
          ),
        ),
      );
    }

    void _goToCreate(BuildContext context) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateGroup(
            userModel: _currentUser,
          ),
        ),
      );
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

    Color green = const Color(0xFFa8e1a6);
    Color blue = const Color(0xFF5ac9fc);
    return Scaffold(
      body: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 40, 20, 0),
                child: IconButton(
                  onPressed: () => _signOut(context),
                  icon: Icon(Icons.exit_to_app),
                  color: Theme.of(context).secondaryHeaderColor,
                ),
              ),
            ],
          ),
          Spacer(
            flex: 1,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              "Welcome to ChoreMate",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 40.0,
                color: Colors.grey[600],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "Since you are not in a household, you can select either " +
                  "to join a household or create one.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.grey[600],
              ),
            ),
          ),
          Spacer(
            flex: 1,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                RaisedButton(
                  child: Text("Create"),
                  onPressed: () => _goToCreate(context),
                  color: Theme.of(context).canvasColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: BorderSide(
                      color: Theme.of(context).secondaryHeaderColor,
                      width: 2,
                    ),
                  ),
                ),
                RaisedButton(
                  child: Text(
                    "Join",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () => _goToJoin(context),
                ),
              ],
            ),
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
                  builder: (context) => todo(),
                ),
                (route) => false,
              );
              break;
            case 2:
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => calendar(),
                ),
                (route) => false,
              );
              break;
            case 3:
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      reminders(),
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
      ),
    );
  }
}
