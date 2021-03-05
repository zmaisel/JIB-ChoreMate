import 'package:cloud_firestore/cloud_firestore.dart';

enum Repeating { daily, weekly, monthly, none, start }

class ChoreModel {
  String choreId;
  String uid;
  String groupId;
  String dueDate;
  String dueTime;
  String status;
  String repeating;
  String name;
  Repeating value;
  //String nextChore;

  ChoreModel({
    this.choreId,
    this.uid,
    this.groupId,
    this.dueDate,
    this.dueTime,
    this.status,
    this.repeating,
    this.name,
    this.value,
    //this.nextChore
  });

  ChoreModel.fromDocumentSnapshot({DocumentSnapshot doc}) {
    choreId = doc.documentID;
    uid = doc.data['uid'];
    groupId = doc.data['groupId'];
    dueDate = doc.data['dueDate'];
    dueTime = doc.data['dueTime'];
    status = doc.data['status'];
    repeating = doc.data['repeating'];
    //nextChore = doc.data['nextChore'];
    name = doc.data['name'];
  }

  Repeating get val => value;
  set val(Repeating newValue) => this.value = newValue;

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (choreId != null) map['choreId'] = choreId;
    map['uid'] = uid;
    map['groupId'] = groupId;
    map['dueDate'] = dueDate;
    map['dueTime'] = dueTime;
    map['status'] = status;
    map['repeating'] = repeating;
    map['name'] = name;
    return map;
  }

//Extract Task object from MAP object
  ChoreModel.fromMapObject(Map<String, dynamic> map) {
    this.choreId = map['choreId'];
    this.uid = map['uid'];
    this.groupId = map['groupId'];
    this.dueDate = map['dueDate'];
    this.dueTime = map['dueTime'];
    this.status = map['status'];
    this.repeating = map['repeating'];
    this.name = map['name'];
  }
}
