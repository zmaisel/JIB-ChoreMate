import 'package:choremate/models/userModel.dart';
import 'package:choremate/screens/root/root.dart';
import 'package:choremate/screens/userData.dart';
import 'package:choremate/services/dbFuture.dart';
import 'package:flutter/material.dart';
import 'package:choremate/screens/chores/todo.dart';

import 'calendar/calendar2.dart';

class GroupDetails extends StatefulWidget {
  final UserModel userModel;
  //final GroupModel groupModel;

  GroupDetails({
    this.userModel,
  });

  @override
  GroupDetailsState createState() => GroupDetailsState();
}

class GroupDetailsState extends State<GroupDetails> {
  final key = new GlobalKey<ScaffoldState>();
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _leaveGroup(BuildContext context) async {
    //GroupModel group = Provider.of<GroupModel>(context, listen: false);
    //UserModel user = Provider.of<UserModel>(context, listen: false);
    //print(group);
    String _returnString =
        await DBFuture().leaveGroup(widget.userModel.groupId, widget.userModel);
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

  int index = 0;

  @override
  Widget build(BuildContext context) {
    Color green = const Color(0xFFa8e1a6);
    Color blue = const Color(0xFF5ac9fc);
    return Scaffold(
      appBar: AppBar(
        title: Text('ChoreMate'),
        backgroundColor: blue,
      ),
      body: ListView(children: <Widget>[
        SizedBox(
          height: 10,
        ),
        // Padding(
        //   padding: const EdgeInsets.all(10.0),
        //   child: ShadowContainer(
        //     child: Column(
        //       children: <Widget>[
        //         Text(widget.userModel.groupName,
        //             style:
        //                 TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
        //         Padding(
        //           padding: const EdgeInsets.symmetric(vertical: 8.0),
        //           child: RaisedButton(
        //             child: Text("Show More"),
        //             onPressed: () async {
        //               List<String> groupMembers = await _listGroupMembers();
        //               // groupMembersList.then((List<String> result){
        //               //                                 setState(() {
        //               //                                   groupMembers = result;
        //               //                                 });
        //               //                               });
        //               Firestore _firestore = Firestore.instance;
        //               FirebaseAuth _auth = FirebaseAuth.instance;
        //               FirebaseUser _firebaseUser = await _auth.currentUser();
        //               List<String> memberNames = new List<String>();
        //               String groupID;
        //               String theUser;
        //               memberNames.clear();
        //               for (int j = 0; j < groupMembers.length; j++) {
        //                 QuerySnapshot querySnapshot =
        //                     await _firestore.collection("users").getDocuments();
        //                 List<DocumentSnapshot> list = querySnapshot.documents;
        //                 print("ATTENTION " + list[0].data.toString());
        //                 theUser = list[0].data["fullName"];
        //                 groupID = list[0].data["groupId"];
        //                 bool cont = true;
        //                 for (int i = 0; i < list.length; i++) {
        //                   var listMembers = list[i].data;
        //                   var listf = listMembers.values.take(20);
        //                   List members = listf.toList(growable: true);
        //                   //print("hehe " + members.toString());

        //                   members.removeAt(0);
        //                   members.removeAt(0);
        //                   members.removeAt(0);
        //                   members.removeAt(0);
        //                   String membersName = members.elementAt(0);
        //                   memberNames.add(membersName);
        //                   print("list " + membersName);
        //                 }
        //                 //groupMembers[j] = document.data[2].toString();
        //               }
        //               for (int j = 0; j < groupMembers.length; j++) {
        //                 DocumentSnapshot member = await _firestore
        //                     .collection("users")
        //                     .document(groupMembers[j])
        //                     .get();
        //                 groupMembers[j] = member.data["fullName"];
        //               }

        //               //String choreName;

        //               QuerySnapshot result = await _firestore
        //                   .collection("groups")
        //                   .document(groupID)
        //                   .collection("chores")
        //                   .getDocuments();
        //               List<DocumentSnapshot> choreList = result.documents;
        //               print(choreList.toString());
        //               List<String> chores = new List<String>();
        //               for (int k = 0; k < choreList.length; k++) {
        //                 String chore = choreList[k]['task'].toString();
        //                 //print(chore);
        //                 String assigned = choreList[k]['assignment'].toString();
        //                 if (assigned == theUser) {
        //                   chores.add(chore);
        //                   print('YAY');
        //                 }
        //               }
        //               print(chores.toString());

        //               //DocumentSnapshot member = await _firestore.collection("users").document(groupMembers[0]).get();

        //               print("hi");
        //               //print(groupMembers.toString());
        //               showDialog(
        //                 context: context,
        //                 builder: (context) {
        //                   return Dialog(
        //                     shape: RoundedRectangleBorder(
        //                         borderRadius: BorderRadius.circular(40)),
        //                     elevation: 16,
        //                     child: Container(
        //                         height: 400.0,
        //                         width: 360.0,
        //                         child: ListView.builder(
        //                             padding: const EdgeInsets.all(8),
        //                             itemCount: groupMembers.length,
        //                             itemBuilder:
        //                                 (BuildContext context, int index) {
        //                               return Container(
        //                                 height: 50,
        //                                 margin: EdgeInsets.all(2),
        //                                 child: Center(
        //                                   child: new GestureDetector(
        //                                       onTap: () {
        //                                         showDialog(
        //                                             context: context,
        //                                             builder:
        //                                                 (BuildContext context) {
        //                                               return AlertDialog(
        //                                                 title:
        //                                                     Text('Chore Data'),
        //                                                 content: Text('User: ' +
        //                                                     '${groupMembers[index]}' +
        //                                                     '\n' +
        //                                                     'Household: ' +
        //                                                     widget.userModel
        //                                                         .groupName +
        //                                                     '\n' +
        //                                                     'Incomplete Chores:' +
        //                                                     '\n' +
        //                                                     '${chores[index]}' +
        //                                                     '\n'),
        //                                               );
        //                                             });
        //                                       },
        //                                       child: Text(
        //                                           '${groupMembers[index]}',
        //                                           style:
        //                                               TextStyle(fontSize: 18))),
        //                                 ),
        //                               );
        //                             })),
        //                   );
        //                 },
        //               );
        //             },
        //           ),
        //         )
        //       ],
        //     ),
        //   ),
        // ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(widget.userModel.groupName,
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
        ),

        SizedBox(
          height: MediaQuery.of(context).size.height,
          child: FutureBuilder(
            future: DBFuture().getUserList(widget.userModel.groupId),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.data == null) {
                return Text("Loading");
              } else {
                if (snapshot.data.length < 1) {
                  return Center(
                    child: Text(
                      'Household has no members',
                      style: TextStyle(fontSize: 20),
                    ),
                  );
                }
                return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int position) {
                      return new GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      UserData(userModel: widget.userModel),
                                ));
                          },
                          child: Card(
                              margin: EdgeInsets.all(1.0),
                              elevation: 2.0,
                              child: ListTile(
                                  leading: Icon(Icons.person, color: blue),
                                  title: Text(snapshot.data[position]),
                                  trailing:
                                      Icon(Icons.arrow_forward_ios))) //Card
                          );
                    });
              }
            },
          ),
        ),
      ]),
      bottomSheet: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20),
        child: RaisedButton(
          child: Text("Leave Group"),
          onPressed: () => _leaveGroup(context),
          //color: green,
        ),
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
            case 2:
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => Calendar(userModel: widget.userModel),
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
            title: Text('Notifcations'),
            backgroundColor: blue,
          )
        ],
      ),
    );
  }
}
