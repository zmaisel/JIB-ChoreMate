import 'package:choremate/models/userModel.dart';
import 'package:choremate/screens/root/root.dart';
import 'package:choremate/services/dbFuture.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:choremate/widgets/shadowContainer.dart';
import 'package:provider/provider.dart';

//mport 'package:numberpicker/numberpicker.dart';

class AddMembers extends StatefulWidget {
  final bool onGroupCreation;
  final bool onError;
  final String groupName;
  final UserModel currentUser;

  AddMembers({
    this.onGroupCreation,
    this.onError,
    this.groupName,
    this.currentUser,
  });
  @override
  _AddMembersState createState() => _AddMembersState();
}

class _AddMembersState extends State<AddMembers> {
  TextEditingController _memberController = TextEditingController();

  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _addMembers(BuildContext context, String groupName) async {
    String _returnString;
    UserModel _currentUser = widget.currentUser;

    print("currentUser:" + _currentUser.toString());

    if (widget.onGroupCreation) {
      _returnString =
          await DBFuture().createGroup(groupName, widget.currentUser);
    }
    if (_returnString == "success") {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => OurRoot(),
          ),
          (route) => false);
    } else {
      print("error adding members");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //key: addBookKey,
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: <Widget>[BackButton()],
            ),
          ),
          SizedBox(
            height: 40,
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ShadowContainer(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _memberController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.book),
                      hintText: "Name",
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  RaisedButton(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 100),
                      child: Text(
                        "Create",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                    onPressed: () {
                      _addMembers(context, widget.groupName);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
