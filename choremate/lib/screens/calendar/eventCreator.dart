import 'package:choremate/models/userModel.dart';
import 'package:choremate/utilities/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:choremate/models/event.dart';
import 'package:intl/intl.dart';

class EventData {
  String title = '';
  DateTime time;
  String summary = '';
}

class EventCreator extends StatefulWidget {
  final Event _event;
  final UserModel userModel;

  @override
  State<StatefulWidget> createState() {
    return new EventCreatorState();
  }

  EventCreator(this._event, this.userModel) {
    createState();
  }
}

class EventCreatorState extends State<EventCreator> {
  final dateFormat = DateFormat("MMMM d, yyyy 'at' h:mma");
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  EventData _eventData = new EventData();
  Utils utility = new Utils();
  Color green = const Color(0xFFa8e1a6);
  Color blue = const Color(0xFF5ac9fc);

  @override
  Widget build(BuildContext context) {
    final titleWidget = new TextFormField(
      keyboardType: TextInputType.text,
      decoration: new InputDecoration(
        hintText: 'Event Name',
        labelText: 'Event Title',
        //contentPadding: EdgeInsets.all(16.0),
        //border: OutlineInputBorder(
        //borderRadius: BorderRadius.circular(8.0),
      ),
      initialValue: widget._event != null ? widget._event.title : '',
      style: Theme.of(context).textTheme.headline5,
      validator: this._validateTitle,
      onSaved: (String value) => this._eventData.title = value,
    );

    final notesWidget = new TextFormField(
      keyboardType: TextInputType.multiline,
      maxLines: 4,
      decoration: InputDecoration(
          hintText: 'Notes',
          labelText: 'Enter your notes here',
          contentPadding: EdgeInsets.all(16.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0))),
      initialValue: widget._event != null ? widget._event.summary : '',
      style: Theme.of(context).textTheme.headline5,
      onSaved: (String value) => this._eventData.summary = value,
    );

    return new Scaffold(
      appBar: new AppBar(
        leading: new BackButton(),
        title: new Text('Create New Event'),
        backgroundColor: blue,
      ),
      body: new Form(
          key: this._formKey,
          child: new Container(
            padding: EdgeInsets.all(10.0),
            child: new Column(
              children: <Widget>[
                titleWidget,
                SizedBox(height: 16.0),
                new DateTimeField(
                  format: dateFormat,
                  onShowPicker: (context, currentValue) async {
                    final date = await showDatePicker(
                        context: context,
                        firstDate: DateTime(1900),
                        initialDate: currentValue ?? DateTime.now(),
                        lastDate: DateTime(2100));
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(
                            currentValue ?? DateTime.now()),
                      );
                      return DateTimeField.combine(date, time);
                    } else {
                      return currentValue;
                    }
                  },
                  validator: this._validateDate,
                  initialValue: DateTime.now(),
                  // onChanged: (date) => setState(() {
                  //   value = date;
                  // }),
                  onSaved: (date) => setState(() {
                    _eventData.time = date;
                  }),
                ),
                SizedBox(height: 16.0),
                notesWidget,
                Padding(
                  padding: EdgeInsets.all(10),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0)),
                    padding: EdgeInsets.all(5),
                    color: blue,
                    textColor: Colors.white,
                    elevation: 5.0,
                    child: Text(
                      "Save",
                      style: new TextStyle(
                          fontSize: 18,
                          fontFamily: "Lato",
                          color: Colors.white),
                      textAlign: TextAlign.center,
                      textScaleFactor: 1.2,
                    ),
                    onPressed: () {
                      setState(() {
                        _saveNewEvent(context);
                      });
                    },
                  ), //RaisedButton
                ),
              ],
            ),
          )),
    );
  }

  String _validateTitle(String value) {
    if (value.isEmpty) {
      return 'Please enter a valid title.';
    } else {
      return null;
    }
  }

  String _validateDate(DateTime value) {
    if ((value != null) &&
        (value.day >= 1 && value.day <= 31) &&
        (value.month >= 1 && value.month <= 12) &&
        (value.year >= 2015 && value.year <= 3000)) {
      return null;
    } else {
      return 'Please enter a valid event date.';
    }
  }

  Future _saveNewEvent(BuildContext context) async {
    FirebaseUser currentUser = await _auth.currentUser();

    if (currentUser != null && this._formKey.currentState.validate()) {
      _formKey.currentState.save(); // Save our form now.

      Firestore.instance
          .collection('groups')
          .document(widget.userModel.groupId)
          .collection("events")
          .document(widget._event != null ? widget._event.id : null)
          .setData({
        'name': _eventData.title,
        'summary': _eventData.summary,
        'time': _eventData.time,
        'uid': widget.userModel.uid,
        'user': widget.userModel.fullName,
        'groupID': widget.userModel.groupId
      });

      Navigator.maybePop(context);
    } else {
      print('Error validating data and saving to firestore.');
    }
  }
}
