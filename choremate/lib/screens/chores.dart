import 'package:choremate/addchore.dart';
import 'package:flutter/material.dart';

class Chores extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ChoreState();
  }
}

class _ChoreState extends State<Chores> {
  //final List<String> _chores = <String>[];
  //final TextEditingController _textFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chores')),
      body:
          //ListView(
          //children: _getItems()),
          //floatingActionButton:
          FloatingActionButton(
              //onPressed: () => _displayDialog(context),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddChore()),
                );
              },
              //tooltip: 'Add Item',
              child: Icon(Icons.add)),
    );
  }

  // void _addTodoItem(String title) {
  //   // Wrapping it inside a set state will notify
  //   // the app that the state has changed
  //   setState(() {
  //     _chores.add(title);
  //   });
  //   _textFieldController.clear();
  // }

  // // Generate list of item widgets
  // Widget _buildTodoItem(String title) {
  //   return ListTile(title: Text(title));
  // }

  // // Generate a single item widget
  // Future<AlertDialog> _displayDialog(BuildContext context) async {
  //   return showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: const Text('Add a chore to your list'),
  //           content: TextField(
  //             controller: _textFieldController,
  //             decoration: const InputDecoration(hintText: 'Enter chore here'),
  //           ),
  //           actions: <Widget>[
  //             FlatButton(
  //               child: const Text('ADD'),
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //                 _addTodoItem(_textFieldController.text);
  //               },
  //             ),
  //             FlatButton(
  //               child: const Text('CANCEL'),
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               },
  //             )
  //           ],
  //         );
  //       });
  // }

  // List<Widget> _getItems() {
  //   final List<Widget> _todoWidgets = <Widget>[];
  //   for (String title in _chores) {
  //     _todoWidgets.add(_buildTodoItem(title));
  //   }
  //   return _todoWidgets;
  // }
}
