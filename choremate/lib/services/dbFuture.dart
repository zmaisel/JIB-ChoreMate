import 'package:choremate/models/task.dart';
//import 'package:choremate/models/reviewModel.dart';
import 'package:choremate/models/userModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:choremate/models/message.dart';

class DBFuture {
  Firestore _firestore = Firestore.instance;

//function to get current group of user
  Future<String> getCurrentGroup() async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    FirebaseUser currentUser = await _auth.currentUser();
    print(currentUser.uid);

    String currentGroupID;
    _firestore
        .collection("users")
        .document(currentUser.uid)
        .get()
        .then((value) {
      currentGroupID = value.data["groupId"];
      print(value.data["groupId"]);
    });
    return currentGroupID;
  }

//function to create a group
  Future<String> createGroup(String groupName, UserModel user) async {
    String retVal = "error";
    List<String> members = List();
    List<String> memberNames = List();
    List<String> tokens = List();

    try {
      members.add(user.uid);
      memberNames.add(user.fullName);
      tokens.add(user.notifToken);
      DocumentReference _docRef;
      if (user.notifToken != null) {
        //print("made it here!");
        _docRef = await _firestore.collection("groups").add({
          'name': groupName.trim(),
          'leader': user.uid,
          'members': members,
          'memberNames': memberNames,
          'tokens': tokens,
          'groupCreated': Timestamp.now(),
        });
      } else {
        _docRef = await _firestore.collection("groups").add({
          'name': groupName.trim(),
          'leader': user.uid,
          'members': members,
          'memberNames': memberNames,
          'groupCreated': Timestamp.now(),
        });
      }

      await _firestore.collection("users").document(user.uid).updateData({
        'groupId': _docRef.documentID,
        'groupName': groupName.trim(),
      });

      retVal = "success";
    } catch (e) {
      print(e);
    }

    return retVal;
  }

//function to join an existing group
//adds a user to an existing group in firebase
  Future<String> joinGroup(String groupId, UserModel userModel) async {
    String retVal = "error";
    List<String> members = List();
    List<String> tokens = List();
    List<String> memberNames = List();
    try {
      members.add(userModel.uid);
      memberNames.add(userModel.fullName);
      //tokens.add(userModel.notifToken);
      await _firestore.collection("groups").document(groupId).updateData({
        'members': FieldValue.arrayUnion(members),
        'memberNames': FieldValue.arrayUnion(memberNames),
        //'tokens': FieldValue.arrayUnion(tokens),
      });

      String groupName;
      await _firestore
          .collection("groups")
          .document(groupId)
          .get()
          .then((value) {
        groupName = value.data["name"].toString();
      });
      print(groupName);

      await _firestore.collection("users").document(userModel.uid).updateData({
        'groupId': groupId.trim(),
        'groupName': groupName.trim(),
      });

      retVal = "success";
    } on PlatformException catch (e) {
      retVal = "Make sure you have the right group ID!";
      print(e);
    } catch (e) {
      print(e);
    }

    return retVal;
  }

//function to leave a group
//removes the user's name and user id from the lists in the group
  Future<String> leaveGroup(String groupId, UserModel userModel) async {
    String retVal = "error";
    List<String> members = List();
    List<String> tokens = List();
    List<String> memberNames = List();
    try {
      members.add(userModel.uid);
      memberNames.add(userModel.fullName);
      //tokens.add(userModel.notifToken);
      await _firestore.collection("groups").document(groupId).updateData({
        'members': FieldValue.arrayRemove(members),
        'tokens': FieldValue.arrayRemove(tokens),
        'memberNames': FieldValue.arrayRemove(memberNames),
      });

      await _firestore.collection("users").document(userModel.uid).updateData({
        'groupId': null,
      });
    } catch (e) {
      print(e);
    }

    return retVal;
  }

  //method to add chore
  // creates a new collection in the group called chores if it doesn't already exist
  // if chores already exist, adds to the existing collection a new document with the
  // chore data stored in the chore variable
  Future<Task> addChore(
      Task chore, String groupID, String fullName, String uid) async {
    String retVal = "error";

    try {
      DocumentReference _docRef = await _firestore
          .collection("groups")
          .document(groupID)
          .collection("chores")
          .add({
        'task': chore.task,
        'date': chore.date,
        'time': chore.time,
        'status': chore.status,
        'rpt': chore.rpt,
        'assignment': chore.assignment
      });
      DocumentSnapshot docSnap = await _docRef.get();

      //print(docSnap.reference.documentID.toString());
      chore.choreID = docSnap.reference.documentID.toString();
      //print("choreID here in DBFuture:" + choreID);
      retVal = "success";
    } catch (e) {
      print(e);
    }
    // gets the user id of who the chore is assigned to
    chore.assignmentUID = await getAssignment(groupID, chore);
    //chore.choreIDUser = await assignChore(chore);
    updateChore(groupID, chore);
    //add the chore to the events collection so that it adds to the calendar too
    await _firestore
        .collection("groups")
        .document(groupID)
        .collection("events")
        .document(chore.choreID)
        .setData({
      'groupID': groupID,
      'name': chore.task,
      'summary': ("Chore assigned to: " + chore.assignment),
      'time': chore.dateTime,
      'uid': chore.assignmentUID,
      'user': chore.assignment,
    });
    return chore;
    //return retVal;
  }

  //get the user id of the user the chore is assigned to
  Future<String> getAssignment(String groupID, Task chore) async {
    List<String> userList = await getUserList(groupID);
    String uidAssigned;
    for (int i = 0; i < userList.length; i++) {
      if (userList.elementAt(i).contains(chore.assignment)) {
        List<String> uidList = await getUIDList(groupID);
        uidAssigned = uidList.elementAt(i);
      }
    }
    return uidAssigned;
  }

//not using this method anymore, storing the user id of assignment in the chore
//rather than storing the chore in two places (by also storing it in collection
//in the user)
  Future<String> assignChore(Task chore) async {
    DocumentReference doc = await _firestore
        .collection("users")
        .document(chore.assignmentUID)
        .collection("chores")
        .add({
      //'choreID': chore.choreID,
      'task': chore.task,
      'date': chore.date,
      'time': chore.time,
      'status': chore.status,
      'rpt': chore.rpt,
      'assignment': chore.assignment,
      'assignmentUID': chore.assignmentUID
    });
    DocumentSnapshot docSnap = await doc.get();
    chore.choreIDUser = docSnap.reference.documentID.toString();
    return chore.choreIDUser;
  }

  Future<String> updateChore(String groupId, Task chore) async {
    String retVal = "error";
    try {
      await _firestore
          .collection("groups")
          .document(groupId)
          .collection("chores")
          .document(chore.choreID)
          .updateData({
        'choreID': chore.choreID,
        'task': chore.task,
        'date': chore.date,
        'time': chore.time,
        'status': chore.status,
        'rpt': chore.rpt,
        'assignment': chore.assignment,
        'assignmentUID': chore.assignmentUID,
      });

      retVal = "success";
      //return choreID;
    } catch (e) {
      print(e);
    }
    return retVal;
  }

//method to complete chore
//adds the chore to the completed chore collection
//deletes the chore from the chores collection
  Future<String> completeChore(Task chore, String groupId, String uid) async {
    String retVal = "error";
    //first add the chore to to completed collection
    try {
      await _firestore
          .collection("groups")
          .document(groupId)
          .collection("completedChores")
          .add({
        'choreID': chore.choreID,
        'task': chore.task,
        'date': chore.date,
        'time': chore.time,
        'status': chore.status,
        'rpt': chore.rpt,
        'assignment': chore.assignment,
        'assignmentUID': chore.assignmentUID
      });
      retVal = "success";
    } catch (e) {
      print(e);
    }
    //delete the chore from the incomplete collection
    try {
      await _firestore
          .collection("groups")
          .document(groupId)
          .collection("chores")
          .document(chore.choreID)
          .delete();
      retVal = "success";
      //print(retVal);
    } catch (e) {
      print("not deleting");
      print(e);
    }
    //delete the chore from the assigned user's chore list
    // try {
    //   print(chore.choreIDUser);
    //   await _firestore
    //       .collection("users")
    //       .document(chore.assignmentUID)
    //       .collection("chores")
    //       .document(chore.choreIDUser)
    //       .delete();
    //   retVal = "success";
    //   //print(chore.choreIDUser);
    // } catch (e) {
    //   print(e);
    // }

    return retVal;
  }

  Future<String> deleteChore(String groupID, String choreID) async {
    String retVal = "error";
    try {
      await _firestore
          .collection("groups")
          .document(groupID)
          .collection("chores")
          .document(choreID)
          .delete();
      retVal = "success";
    } catch (e) {
      print(e);
    }
    try {
      await _firestore
          .collection('groups')
          .document(groupID)
          .collection('events')
          .document(choreID)
          .delete();
    } catch (e) {
      print(e);
    }

    return retVal;
  }

//get the chores in a map list from the database
  Future<List<Map<String, dynamic>>> getChoreMapList(String groupID) async {
    final QuerySnapshot result = await _firestore
        .collection("groups")
        .document(groupID)
        .collection("chores")
        .getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    var choreMapList = List<Map<String, dynamic>>();
    for (int i = 0; i < documents.length; i++) {
      choreMapList.add(documents.elementAt(i).data);
    }

    return choreMapList;
  }

  //get the chore list to display
  Future<List<Task>> getChoreList(String groupID) async {
    List<Task> choreList = List<Task>();

    try {
      //THIS DOESN'T WORK FOR SOME REASON
      var choreMapList =
          await getChoreMapList(groupID); //Get Map List from database
      int count = choreMapList.length;

      //For loop to create Task List from a Map List
      for (int i = 0; i < count; i++) {
        choreList.add(Task.fromMapObject(choreMapList[i]));
        //choreList[i].
      }
    } catch (e) {
      //print("Here is what isn't working.");
      print(e);
    }

    return choreList;
  }

  //get the completed chores in a map list from the data base
  Future<List<Map<String, dynamic>>> getCompletedChoreMapList(
      String groupID) async {
    var choreMapList = List<Map<String, dynamic>>();
    try {
      final QuerySnapshot result = await _firestore
          .collection("groups")
          .document(groupID)
          .collection("completedChores")
          .getDocuments();
      final List<DocumentSnapshot> documents = result.documents;
      for (int i = 0; i < documents.length; i++) {
        choreMapList.add(documents.elementAt(i).data);
      }
    } catch (e) {
      print(e);
    }
    return choreMapList;
  }

  //get the completed chore list to display
  Future<List<Task>> getCompletedChoreList(String groupID) async {
    List<Task> choreList = List<Task>();

    try {
      var choreMapList =
          await getCompletedChoreMapList(groupID); //Get Map List from database
      int count = choreMapList.length;

      //For loop to create Task List from a Map List
      for (int i = 0; i < count; i++) {
        choreList.add(Task.fromMapObject(choreMapList[i]));
      }
    } catch (e) {
      //print("Here is what isn't working.");
      print(e);
    }

    return choreList;
  }

  //method to determine which chore list to display, user or household chorelist
  Future<List<Task>> determineChoreList(
      String value, String groupID, String uid) async {
    List<Task> retList = List();
    //print("dropdownValue:" + value);
    if (value.compareTo("My Chores") == 0) {
      retList = await getUserChoreList(uid, groupID);
    } else {
      retList = await getChoreList(groupID);
      print(retList);
    }
    return retList;
  }

  // Future<List<Map<String, dynamic>>> getUserChoreMapList(String uid) async {
  //   final QuerySnapshot result = await _firestore
  //       .collection("users")
  //       .document(uid)
  //       .collection("chores")
  //       .getDocuments();
  //   final List<DocumentSnapshot> documents = result.documents;
  //   var choreMapList = List<Map<String, dynamic>>();
  //   for (int i = 0; i < documents.length; i++) {
  //     choreMapList.add(documents.elementAt(i).data);
  //REMINDERS

// method to add a reminder
// adds the message to the reminders collection of the group
  Future<Message> addReminder(String groupId, Message message) async {
    String retVal = "error";

    try {
      DocumentReference _docRef2 = await _firestore
          .collection("groups")
          .document(groupId)
          .collection("reminders")
          .add({
        'messageID': "",
        'message': message.message,
        'sentTo': message.sentTo
      });
      DocumentSnapshot docSnap = await _docRef2.get();

      //print(docSnap.reference.documentID.toString());
      message.messageID = docSnap.reference.documentID.toString();

      retVal = "success";
      message.sentToUID = await getSentTo(groupId, message);
      updateReminder(message, groupId);
      return message;
    } catch (e) {
      print(e);
    }
    return message;
  }

  Future<String> updateReminder(Message message, String groupId) async {
    String retVal = "error";
    try {
      await _firestore
          .collection("groups")
          .document(groupId)
          .collection("reminders")
          .document(message.messageID)
          .updateData({
        'messageID': message.messageID,
        'sentToUID': message.sentToUID,
      });
      retVal = "success";
    } catch (e) {
      print(e);
    }

    return retVal;
  }

// method to determine who the reminder was sent to
  Future<String> getSentTo(String groupID, Message message) async {
    List<String> userList = await getUserList(groupID);
    String sentToUID;
    for (int i = 0; i < userList.length; i++) {
      if (userList.elementAt(i).contains(message.sentTo)) {
        List<String> uidList = await getUIDList(groupID);
        sentToUID = uidList.elementAt(i);
      }
    }
    return sentToUID;
  }

// method to delete reminder
  Future<String> deleteReminder(String groupID, String messageID) async {
    String retVal = "error";
    try {
      await _firestore
          .collection("groups")
          .document(groupID)
          .collection("reminders")
          .document(messageID)
          .delete();
      retVal = "success";
    } catch (e) {
      print(e);
    }

    return retVal;
  }

//get the reminders for a given group in a map list from the database
  Future<List<Map<String, dynamic>>> getReminderMapList(String groupID) async {
    final QuerySnapshot result = await _firestore
        .collection("groups")
        .document(groupID)
        .collection("reminders")
        .getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    var reminderMapList = List<Map<String, dynamic>>();
    for (int i = 0; i < documents.length; i++) {
      reminderMapList.add(documents.elementAt(i).data);
    }

    return reminderMapList;
  }

  //get the reminder list to display
  Future<List<Message>> getReminderList(String groupID, String uid) async {
    List<Message> reminderList = List<Message>();
    List<Message> myReminders = List<Message>();

    try {
      var reminderMapList =
          await getReminderMapList(groupID); //Get Map List from database
      int count = reminderMapList.length;
      //For loop to create Message List from a Map List
      for (int i = 0; i < count; i++) {
        reminderList.add(Message.fromMapObject(reminderMapList[i]));
      }
      for (int i = 0; i < count; i++) {
        if (reminderList.elementAt(i).sentToUID.compareTo(uid) == 0) {
          myReminders.add(reminderList.elementAt(i));
        }
      }
    } catch (e) {
      print("Here is what isn't working.");
      print(e);
    }

    return myReminders;
  }

  //get the chore list to display for the user
  Future<List<Task>> getUserChoreList(String uid, String groupID) async {
    List<Task> choreList = List<Task>();
    List<Task> userChoreList = List<Task>();

    try {
      var choreMapList =
          await getChoreMapList(groupID); //Get Map List from database
      int count = choreMapList.length;

      //For loop to create Task List from a Map List
      for (int i = 0; i < count; i++) {
        choreList.add(Task.fromMapObject(choreMapList[i]));
        //choreList[i].
      }

      for (int i = 0; i < count; i++) {
        if (choreList.elementAt(i).assignmentUID.compareTo(uid) == 0) {
          userChoreList.add(choreList.elementAt(i));
        }
      }
    } catch (e) {
      print(e);
    }

    return userChoreList;
  }

  Future<List<Task>> getUserCompletedList(String uid, String groupID) async {
    List<Task> choreList = List<Task>();
    List<Task> userChoreList = List<Task>();

    try {
      var choreMapList =
          await getCompletedChoreMapList(groupID); //Get Map List from database
      int count = choreMapList.length;

      //For loop to create Task List from a Map List
      for (int i = 0; i < count; i++) {
        choreList.add(Task.fromMapObject(choreMapList[i]));
        //choreList[i].
      }

      for (int i = 0; i < count; i++) {
        if (choreList.elementAt(i).assignmentUID.compareTo(uid) == 0) {
          userChoreList.add(choreList.elementAt(i));
        }
      }
    } catch (e) {
      print(e);
    }

    return userChoreList;
  }

//returns a list of the names of the users in a group
  Future<List<String>> getUserList(String groupID) async {
    DocumentSnapshot document =
        await _firestore.collection("groups").document(groupID).get();
    List<String> userList = List.from(document['memberNames']);
    print(userList);
    return userList;
  }

  Future<List<String>> getUIDList(String groupID) async {
    DocumentSnapshot document =
        await _firestore.collection("groups").document(groupID).get();
    List<String> userList = List.from(document['members']);

    return userList;
  }

//create a new user
//adds a new user to the user collection
  Future<String> createUser(UserModel user) async {
    String retVal = "error";

    try {
      await _firestore.collection("users").document(user.uid).setData({
        'fullName': user.fullName.trim(),
        'email': user.email.trim(),
        'accountCreated': Timestamp.now(),
        'notifToken': user.notifToken,
      });
      retVal = "success";
    } catch (e) {
      print(e);
    }

    return retVal;
  }

//get the user from the database
  Future<UserModel> getUser(String uid) async {
    UserModel retVal;

    try {
      DocumentSnapshot _docSnapshot =
          await _firestore.collection("users").document(uid).get();
      retVal = UserModel.fromDocumentSnapshot(doc: _docSnapshot);
    } catch (e) {
      print(e);
    }

    return retVal;
  }
}
