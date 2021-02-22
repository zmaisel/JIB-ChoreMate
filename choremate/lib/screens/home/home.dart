import 'package:choremate/states/currentUser.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:choremate/screens/root/root.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("THIS IS HOME"),
      ),
      body: Center(
          child: RaisedButton(
        child: Text("Sign Out"),
        onPressed: () async {
          CurrentUser _currentUser =
              Provider.of<CurrentUser>(context, listen: false);
          String _returnString = await _currentUser.signOut();
          if (_returnString == "success") {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => OurRoot(),
                ),
                (route) => false);
          }
        },
      )),
    );
  }
}
