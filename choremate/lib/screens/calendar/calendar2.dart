import 'dart:async';

import 'package:choremate/models/userModel.dart';
import 'package:choremate/screens/calendar/eventCreator.dart';
import 'package:choremate/screens/reminders/reminders.dart';
import 'package:choremate/screens/root/root.dart';
import 'package:choremate/screens/chores/todo.dart';
import 'package:choremate/screens/calendar/viewEvent.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:choremate/models/event.dart';

class Calendar extends StatefulWidget {
  //final bool darkThemeEnabled;
  //calendar(this.darkThemeEnabled);
  final UserModel userModel;
  Calendar({this.userModel});

  @override
  State<StatefulWidget> createState() {
    return CalendarState();
  }
}

class CalendarState extends State<Calendar> {
  //final FirebaseAuth _auth = FirebaseAuth.instance;
  //final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  DateTime _dateTime;
  QuerySnapshot _userEventSnapshot;
  int _beginMonthPadding = 0;
  int index = 2;
  Color green = const Color(0xFFa8e1a6);
  Color blue = const Color(0xFF5ac9fc);

  CalendarState() {
    _dateTime = DateTime.now();
    setMonthPadding();
  }

  @override
  void initState() {
    super.initState();
  }

  void setMonthPadding() {
    _beginMonthPadding =
        new DateTime(_dateTime.year, _dateTime.month, 1).weekday;
    _beginMonthPadding == 7 ? (_beginMonthPadding = 0) : _beginMonthPadding;
  }

  Future<QuerySnapshot> _getCalendarData() async {
    //FirebaseUser currentUser = await _auth.currentUser();

    if (widget.userModel != null) {
      QuerySnapshot userEvents = await Firestore.instance
          .collection('groups')
          .document(widget.userModel.groupId)
          .collection("events")
          // .where('time',
          //     isGreaterThanOrEqualTo:
          //         new DateTime(_dateTime.year, _dateTime.month))
          .getDocuments();

      _userEventSnapshot = userEvents;
      return _userEventSnapshot;
    } else {
      return null;
    }
  }

  void _goToToday() {
    print("trying to go to the month of today");
    setState(() {
      _dateTime = DateTime.now();

      setMonthPadding();
    });
  }

  void _previousMonthSelected() {
    setState(() {
      if (_dateTime.month == DateTime.january)
        _dateTime = new DateTime(_dateTime.year - 1, DateTime.december);
      else
        _dateTime = new DateTime(_dateTime.year, _dateTime.month - 1);

      setMonthPadding();
    });
  }

  void _nextMonthSelected() {
    setState(() {
      if (_dateTime.month == DateTime.december)
        _dateTime = new DateTime(_dateTime.year + 1, DateTime.january);
      else
        _dateTime = new DateTime(_dateTime.year, _dateTime.month + 1);

      setMonthPadding();
    });
  }

  void _onDayTapped(int day) {
    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (BuildContext context) => new EventsView(
                new DateTime(_dateTime.year, _dateTime.month, day),
                widget.userModel)));
  }

  void _onFabClicked() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EventCreator(null, widget.userModel)));
  }

  @override
  Widget build(BuildContext context) {
    final int numWeekDays = 7;
    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    /*28 is for weekday labels of the row*/
    // 55 is for iPhoneX clipping issue.
    final double itemHeight = (size.height -
            kToolbarHeight -
            kBottomNavigationBarHeight -
            24 -
            28 -
            55) /
        6;
    final double itemWidth = size.width / numWeekDays;

    return new Scaffold(
        backgroundColor: Colors.white,
        appBar: new AppBar(
          backgroundColor: blue,
          title: new FittedBox(
              fit: BoxFit.contain,
              child: new Text(
                getMonthName(_dateTime.month) + " " + _dateTime.year.toString(),
              )),
          actions: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.today,
                  color: Colors.white,
                ),
                onPressed: _goToToday),
            IconButton(
                icon: Icon(
                  Icons.chevron_left,
                  color: Colors.white,
                ),
                onPressed: _previousMonthSelected),
            IconButton(
                icon: Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                ),
                onPressed: _nextMonthSelected),
          ],
        ),
        floatingActionButton: new FloatingActionButton(
          onPressed: _onFabClicked,
          child: new Icon(Icons.add),
          backgroundColor: green,
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
                    builder: (context) => todo(userModel: widget.userModel),
                  ),
                  (route) => false,
                );
                break;
              case 3:
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        reminders(userModel: widget.userModel),
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
        body: new FutureBuilder(
            future: _getCalendarData(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return new LinearProgressIndicator();
                case ConnectionState.done:
                  return new Column(
                    children: <Widget>[
                      new Row(
                        children: <Widget>[
                          new Expanded(
                              child: new Text('S',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.headline)),
                          new Expanded(
                              child: new Text('M',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.headline)),
                          new Expanded(
                              child: new Text('T',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.headline)),
                          new Expanded(
                              child: new Text('W',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.headline)),
                          new Expanded(
                              child: new Text('T',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.headline)),
                          new Expanded(
                              child: new Text('F',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.headline)),
                          new Expanded(
                              child: new Text('S',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.headline)),
                        ],
                        mainAxisSize: MainAxisSize.min,
                      ),
                      new GridView.count(
                        crossAxisCount: numWeekDays,
                        childAspectRatio: (itemWidth / itemHeight),
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        children: List.generate(
                            getNumberOfDaysInMonth(_dateTime.month), (index) {
                          int dayNumber = index + 1;
                          return new GestureDetector(
                              // Used for handling tap on each day view
                              onTap: () =>
                                  _onDayTapped(dayNumber - _beginMonthPadding),
                              child: new Container(
                                  margin: const EdgeInsets.all(2.0),
                                  padding: const EdgeInsets.all(1.0),
                                  decoration: new BoxDecoration(
                                      border:
                                          new Border.all(color: Colors.grey)),
                                  child: new Column(
                                    children: <Widget>[
                                      buildDayNumberWidget(dayNumber),
                                      buildDayEventInfoWidget(dayNumber)
                                    ],
                                  )));
                        }),
                      )
                    ],
                  );
                  break;
                default:
                  if (snapshot.hasError)
                    return new Text('Error: ${snapshot.error}');
                  else
                    return new Text('Result: ${snapshot.data}');
              }
            }));
  }

  Align buildDayNumberWidget(int dayNumber) {
    //print('buildDayNumberWidget, dayNumber: $dayNumber');
    if ((dayNumber - _beginMonthPadding) == DateTime.now().day &&
        _dateTime.month == DateTime.now().month &&
        _dateTime.year == DateTime.now().year) {
      // Add a circle around the current day
      return Align(
        alignment: Alignment.topLeft,
        child: Container(
          width: 35.0, // Should probably calculate these values
          height: 35.0,
          padding: EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: green,
            border: Border.all(),
          ),
          child: new Text(
            (dayNumber - _beginMonthPadding).toString(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.title,
          ),
        ),
      );
    } else {
      // No circle around the current day
      return Align(
        alignment: Alignment.topLeft,
        child: Container(
          width: 35.0, // Should probably calculate these values
          height: 35.0,
          padding: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
          child: new Text(
            dayNumber <= _beginMonthPadding
                ? ' '
                : (dayNumber - _beginMonthPadding).toString(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline,
          ),
        ),
      );
    }
  }

  Widget buildDayEventInfoWidget(int dayNumber) {
    int eventCount = 0;
    DateTime eventDate;
    try {
      //print(_userEventSnapshot.documents.);
      _userEventSnapshot.documents.forEach((doc) {
        eventDate = DateTime.fromMicrosecondsSinceEpoch(
            doc.data['time'].microsecondsSinceEpoch);
        if (eventDate != null &&
            eventDate.day == dayNumber - _beginMonthPadding &&
            eventDate.month == _dateTime.month &&
            eventDate.year == _dateTime.year) {
          eventCount++;
        }
      });
    } catch (e) {
      print(e);
    }

    if (eventCount > 0) {
      return new Expanded(
        child: FittedBox(
          alignment: Alignment.topLeft,
          fit: BoxFit.contain,
          child: new Text(
            "Events:$eventCount",
            maxLines: 1,
            style: new TextStyle(
                fontWeight: FontWeight.normal,
                background: Paint()..color = blue),
          ),
        ),
      );
    } else {
      return new Container();
    }
  }

  int getNumberOfDaysInMonth(final int month) {
    int numDays = 28;

    // Months are 1, ..., 12
    switch (month) {
      case 1:
        numDays = 31;
        break;
      case 2:
        numDays = 28;
        break;
      case 3:
        numDays = 31;
        break;
      case 4:
        numDays = 30;
        break;
      case 5:
        numDays = 31;
        break;
      case 6:
        numDays = 30;
        break;
      case 7:
        numDays = 31;
        break;
      case 8:
        numDays = 31;
        break;
      case 9:
        numDays = 30;
        break;
      case 10:
        numDays = 31;
        break;
      case 11:
        numDays = 30;
        break;
      case 12:
        numDays = 31;
        break;
      default:
        numDays = 28;
    }
    return numDays + _beginMonthPadding;
  }

  String getMonthName(final int month) {
    // Months are 1, ..., 12
    switch (month) {
      case 1:
        return "January";
      case 2:
        return "February";
      case 3:
        return "March";
      case 4:
        return "April";
      case 5:
        return "May";
      case 6:
        return "June";
      case 7:
        return "July";
      case 8:
        return "August";
      case 9:
        return "September";
      case 10:
        return "October";
      case 11:
        return "November";
      case 12:
        return "December";
      default:
        return "Unknown";
    }
  }
}
