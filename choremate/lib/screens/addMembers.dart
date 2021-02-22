// import 'package:choremate/models/userModel.dart';
// import 'package:choremate/models/task.dart';
// import 'package:choremate/screens/root/root.dart';
// import 'package:choremate/services/dbFuture.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:choremate/widgets/shadowContainer.dart';

// //mport 'package:numberpicker/numberpicker.dart';

// class AddMembers extends StatefulWidget {
//   final bool onGroupCreation;
//   final bool onError;
//   final String groupName;
//   final UserModel currentUser;

//   AddMembers({
//     this.onGroupCreation,
//     this.onError,
//     this.groupName,
//     this.currentUser,
//   });
//   @override
//   _AddMembersState createState() => _AddMembersState();
// }

// class _AddMembersState extends State<AddMembers> {
//   TextEditingController _memberController = TextEditingController();
// }

// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     //key: addBookKey,
//     body: ListView(
//       children: <Widget>[
//         Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Row(
//             children: <Widget>[BackButton()],
//           ),
//         ),
//         SizedBox(
//           height: 40,
//         ),
//         Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: ShadowContainer(
//             child: Column(
//               children: <Widget>[
//                 TextFormField(
//                   controller: _memberController,
//                   decoration: InputDecoration(
//                     prefixIcon: Icon(Icons.book),
//                     hintText: "Name",
//                   ),
//                 ),
//                 SizedBox(
//                   height: 20.0,
//                 ),
//                 // TextFormField(
//                 //   controller: _authorController,
//                 //   decoration: InputDecoration(
//                 //     prefixIcon: Icon(Icons.person_outline),
//                 //     hintText: "Author",
//                 //   ),
//                 // ),
//                 // SizedBox(
//                 //   height: 20.0,
//                 // ),
//                 // TextFormField(
//                 //   controller: _lengthController,
//                 //   decoration: InputDecoration(
//                 //     prefixIcon: Icon(Icons.format_list_numbered),
//                 //     hintText: "Length",
//                 //   ),
//                 //   keyboardType: TextInputType.number,
//                 // ),
//                 // SizedBox(
//                 //   height: 20.0,
//                 // ),
//                 // Text(DateFormat.yMMMMd("en_US").format(_selectedDate)),
//                 // Text(DateFormat("H:00").format(_selectedDate)),
//                 // Row(
//                 //   children: [
//                 //     Expanded(
//                 //       child: FlatButton(
//                 //         child: Text("Change Date"),
//                 //         onPressed: () => _selectDate(),
//                 //       ),
//                 //     ),
//                 //     Expanded(
//                 //       child: FlatButton(
//                 //         child: Text("Change Time"),
//                 //         onPressed: () => _selectTime(),
//                 //       ),
//                 //     ),
//                 //   ],
//                 // ),
//                 RaisedButton(
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 100),
//                     child: Text(
//                       "Create",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 20.0,
//                       ),
//                     ),
//                   ),
//                   onPressed: () {
//                     Task task = Task();
//                     if (_memberController.text == "") {
//                       addBookKey.currentState.showSnackBar(SnackBar(
//                         content: Text("Need to add book name"),
//                       ));
//                     } else if (_authorController.text == "") {
//                       addBookKey.currentState.showSnackBar(SnackBar(
//                         content: Text("Need to add author"),
//                       ));
//                     } else if (_lengthController.text == "") {
//                       addBookKey.currentState.showSnackBar(SnackBar(
//                         content: Text("Need to add book length"),
//                       ));
//                     } else {
//                       book.name = _bookNameController.text;
//                       book.author = _authorController.text;
//                       book.length = int.parse(_lengthController.text);
//                       book.dateCompleted = Timestamp.fromDate(_selectedDate);

//                       _addMembers(context, widget.groupName, book);
//                     }
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }
