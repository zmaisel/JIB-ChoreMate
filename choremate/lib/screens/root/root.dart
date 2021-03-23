import 'dart:io';

import 'package:choremate/models/authModel.dart';
import 'package:choremate/models/groupModel.dart';
import 'package:choremate/models/userModel.dart';
import 'package:choremate/screens/inGroup/inGroup.dart';
import 'package:choremate/screens/login/login.dart';
import 'package:choremate/screens/noGroup/noGroup.dart';
import 'package:choremate/screens/splashScreen/splashScreen.dart';
import 'package:choremate/services/dbStream.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:choremate/screens/home_widget.dart';

enum AuthStatus { notLoggedIn, loggedIn, unknown, notInGroup, inGroup }

class OurRoot extends StatefulWidget {
  @override
  _OurRootState createState() => _OurRootState();
}

class _OurRootState extends State<OurRoot> {
  AuthStatus _authStatus = AuthStatus.unknown;
  String currentUid;
  //final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  // @override
  // void initState() {
  //   super.initState();

  //   if (Platform.isIOS) {
  //     _firebaseMessaging
  //         .requestNotificationPermissions(IosNotificationSettings());
  //     _firebaseMessaging.onIosSettingsRegistered.listen((event) {
  //       print("IOS Registered");
  //     });
  //   }

  //   _firebaseMessaging.configure(
  //     onMessage: (Map<String, dynamic> message) async {
  //       print("onMessage: $message");
  //     },
  //     onLaunch: (Map<String, dynamic> message) async {
  //       print("onLaunch: $message");
  //     },
  //     onResume: (Map<String, dynamic> message) async {
  //       print("onResume: $message");
  //     },
  //   );
  // }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    //get the state, check current User, set AuthStatus based on state
    AuthModel _authStream = Provider.of<AuthModel>(context);
    //print("this does work");
    if (_authStream != null) {
      setState(() {
        _authStatus = AuthStatus.loggedIn;
        currentUid = _authStream.uid;
      });
    } else {
      setState(() {
        _authStatus = AuthStatus.notLoggedIn;
      });
    }
    // _authStatus = AuthStatus.notLoggedIn;
    // CurrentUser _currentUser = Provider.of<CurrentUser>(context, listen: false);
    // String _returnString = await _currentUser.onStartUp();
    // if (_returnString == "success") {
    //   //if(_currentUser)
    //   setState(() {
    //     _authStatus = AuthStatus.loggedIn;
    //   });
    //}
  }

  @override
  Widget build(BuildContext context) {
    Widget retVal;

    switch (_authStatus) {
      case AuthStatus.unknown:
        retVal = SplashScreen();
        break;
      case AuthStatus.notLoggedIn:
        retVal = Login();
        break;
      case AuthStatus.loggedIn:
        retVal = StreamProvider<UserModel>.value(
          value: DBStream().getCurrentUser(currentUid),
          child: LoggedIn(),
        );
        break;
      case AuthStatus.notInGroup:
        retVal = NoGroup();
        break;
      case AuthStatus.inGroup:
        retVal = InGroup();
        break;

      default:
    }
    return retVal;
  }
}

class LoggedIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UserModel _userStream = Provider.of<UserModel>(context);
    //print("user not null" + _userStream.fullName);
    Widget retVal;
    if (_userStream != null) {
      if (_userStream.groupId != null) {
        retVal = StreamProvider<GroupModel>.value(
          value: DBStream().getCurrentGroup(_userStream.groupId),
          child: InGroup(
            userModel: _userStream,
          ),
        );
      } else {
        retVal = NoGroup();
      }
    } else {
      retVal = Home();
    }

    return retVal;
  }
}
