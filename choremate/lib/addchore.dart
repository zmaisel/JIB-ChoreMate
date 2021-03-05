import 'package:flutter/material.dart';

class AddChore extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddChoreState();
  }
}

enum Repeating { daily, weekly, monthly }

class _AddChoreState extends State<AddChore> {
  //final List<String> _chores = <String>[];
  final TextEditingController name = TextEditingController();
  final TextEditingController requirements = TextEditingController();
  final TextEditingController assignment = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Repeating _time = Repeating.daily;
    return Scaffold(
        appBar: AppBar(title: const Text('Chores')),
        body: Center(
            child: Column(children: <Widget>[
          Container(
              width: 280,
              padding: EdgeInsets.all(10.0),
              child: TextField(
                controller: name,
                autocorrect: true,
                decoration: InputDecoration(hintText: 'Enter chore name here'),
              )),
          Container(
              width: 280,
              padding: EdgeInsets.all(15.0),
              child: TextField(
                controller: requirements,
                autocorrect: true,
                decoration: InputDecoration(hintText: 'Requirements'),
              )),
          Container(
            width: 280,
            padding: EdgeInsets.only(top: 20.0),
            child: Text('Assign Chore to:'),
          ),
          Container(
              width: 280,
              padding: EdgeInsets.all(10.0),
              child: TextField(
                controller: assignment,
                autocorrect: true,
                decoration: InputDecoration(hintText: 'Enter UserId here'),
              )),
          Container(
            width: 280,
            padding: EdgeInsets.only(top: 20.0),
            child: Text('Repeating?'),
          ),
          RadioListTile<Repeating>(
            title: const Text('Daily'),
            value: Repeating.monthly,
            groupValue: _time,
            onChanged: (Repeating value) {
              setState(() {
                _time = value;
              });
            },
          ),
          RadioListTile<Repeating>(
            title: const Text('Weekly'),
            value: Repeating.weekly,
            groupValue: _time,
            onChanged: (Repeating value) {
              setState(() {
                _time = value;
              });
            },
          ),
          RadioListTile<Repeating>(
            title: const Text('Monthly'),
            value: Repeating.monthly,
            groupValue: _time,
            onChanged: (Repeating value) {
              setState(() {
                _time = value;
              });
            },
          ),
        ])));
  }
}
