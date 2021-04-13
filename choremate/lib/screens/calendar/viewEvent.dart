import 'dart:async';

import 'package:choremate/models/userModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:choremate/models/event.dart';
import 'package:intl/intl.dart';

import 'eventCreator.dart';

class EventsView extends StatefulWidget {
  final DateTime _eventDate;
  final UserModel userModel;

  EventsView(DateTime date, this.userModel) : _eventDate = date;

  @override
  State<StatefulWidget> createState() {
    return EventsViewState(_eventDate);
  }
}

class EventsViewState extends State<EventsView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DateTime _eventDate;
  Color green = const Color(0xFFa8e1a6);
  Color blue = const Color(0xFF5ac9fc);

  EventsViewState(DateTime date) : _eventDate = date;

  Future<QuerySnapshot> _getEvents() async {
    FirebaseUser currentUser = await _auth.currentUser();

    if (currentUser != null) {
      QuerySnapshot events = await Firestore.instance
          .collection('groups')
          .document(widget.userModel.groupId)
          .collection("events")
          .where('time',
              isGreaterThan: new DateTime(_eventDate.year, _eventDate.month,
                  _eventDate.day - 1, 23, 59, 59))
          .where('time',
              isLessThan: new DateTime(
                  _eventDate.year, _eventDate.month, _eventDate.day + 1))
          .getDocuments();
      //print(events);
      return events;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        leading: new BackButton(),
        title: new Text(_eventDate.month.toString() +
            '/' +
            _eventDate.day.toString() +
            '/' +
            _eventDate.year.toString() +
            ' Events'),
        backgroundColor: blue,
      ),
      floatingActionButton: new FloatingActionButton(
        backgroundColor: green,
        onPressed: _onFabClicked,
        child: new Icon(Icons.add),
      ),
      body: FutureBuilder(
          future: _getEvents(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return new LinearProgressIndicator();
              case ConnectionState.done:
              default:
                if (snapshot.hasError)
                  return new Text('Error: ${snapshot.error}');
                else {
                  return ListView(
                    children: snapshot.data.documents.map((document) {
                      DateTime _eventTime = DateTime.fromMicrosecondsSinceEpoch(
                          document.data['time'].microsecondsSinceEpoch);
                      var eventDateFormatter =
                          new DateFormat("MMMM d, yyyy 'at' h:mma");

                      return new GestureDetector(
                          onTap: () => _onCardClicked(document),
                          child: new Card(
                            elevation: 2.0,
                            //shape: Border.all(color: Colors.black),
                            child: new Row(
                              children: <Widget>[
                                new Expanded(
                                  child: new Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      new Container(
                                        padding: EdgeInsets.all(10.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            new Text(
                                              'Event: ',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline6,
                                              textAlign: TextAlign.left,
                                            ),
                                            new Text(document.data['name'],
                                                style: TextStyle(fontSize: 18))
                                          ],
                                        ),
                                      ),
                                      new Container(
                                        padding: EdgeInsets.all(10.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            new Text(
                                              'Time: ',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline6,
                                              textAlign: TextAlign.left,
                                            ),
                                            new Text(
                                                eventDateFormatter
                                                    .format(_eventTime),
                                                style: TextStyle(fontSize: 18))
                                          ],
                                        ),
                                      ),
                                      new Container(
                                        padding: EdgeInsets.all(10.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            new Text('Summary: ',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline6),
                                            new Text(document.data['summary'],
                                                style: TextStyle(fontSize: 18)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                new Container(
                                    child: new IconButton(
                                        color: blue,
                                        iconSize: 30.0,
                                        padding: EdgeInsets.all(5.0),
                                        icon: new Icon(Icons.delete),
                                        onPressed: () =>
                                            _deleteEvent(document))),
                              ],
                            ),
                          ));
                    }).toList(),
                  );
                }
            }
          }),
    );
  }

  void _onCardClicked(DocumentSnapshot document) {
    Event event = new Event(
        document.data['title'],
        document.data['summary'],
        document.data['date'],
        document.data['uid'],
        document.data['user'],
        document['groupID'],
        document.documentID);
    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (BuildContext context) =>
                new EventCreator(event, widget.userModel)));
  }

  void _deleteEvent(DocumentSnapshot document) {
    setState(() {
      Firestore.instance
          .collection("groups")
          .document(widget.userModel.groupId)
          .collection('events')
          .document(document.documentID)
          .delete();
      try {
        Firestore.instance
            .collection("groups")
            .document(widget.userModel.groupId)
            .collection('chores')
            .document(document.documentID)
            .delete();
      } catch (e) {
        print(e);
      }
    });
  }

  void _onFabClicked() {
    DateTime _createDateTime = new DateTime(_eventDate.year, _eventDate.month,
        _eventDate.day, DateTime.now().hour, DateTime.now().minute);

    Event _event = new Event("", '', _createDateTime, "", "", "", "");

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EventCreator(_event, widget.userModel)));
  }
}
