import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String uid;
  String email;
  Timestamp accountCreated;
  String fullName;
  String groupId;
  String groupName;
  String notifToken;
  List<String> currentChores;
  //String nextChore;

  UserModel({
    this.uid,
    this.email,
    this.accountCreated,
    this.fullName,
    this.groupId,
    this.groupName,
    this.notifToken,
    this.currentChores,
    //this.nextChore
  });

  UserModel.fromDocumentSnapshot({DocumentSnapshot doc}) {
    uid = doc.documentID;
    email = doc.data['email'];
    accountCreated = doc.data['accountCreated'];
    fullName = doc.data['fullName'];
    groupId = doc.data['groupId'];
    groupName = doc.data['groupName'];
    notifToken = doc.data['notifToken'];
    //nextChore = doc.data['nextChore'];
    currentChores = List<String>.from(doc.data["currentChores"]);
  }
}
