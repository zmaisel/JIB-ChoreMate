import 'package:choremate/models/task.dart';
//import 'package:choremate/models/reviewModel.dart';
import 'package:choremate/models/userModel.dart';
import 'package:choremate/states/currentUser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DBFuture {
  Firestore _firestore = Firestore.instance;

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
        print("made it here!");
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

      //add a book
      //addBook(_docRef.documentID, initialChore);

      retVal = "success";
    } catch (e) {
      print(e);
    }

    return retVal;
  }

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

  Future<String> addChore(
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
      updateChore(groupID, chore);
    } catch (e) {
      print(e);
    }
    if (chore.assignment.contains(fullName)) {
      await _firestore
          .collection("users")
          .document(uid)
          .collection("chores")
          .add({
        'task': chore.task,
        'date': chore.date,
        'time': chore.time,
        'status': chore.status,
        'rpt': chore.rpt,
        'assignment': chore.assignment
      });
    } else {
      List<String> userList = await getUserList(groupID);
      for (int i = 0; i < userList.length; i++) {
        if (userList.elementAt(i).contains(chore.assignment)) {
          List<String> uidList = await getUIDList(groupID);

          await _firestore
              .collection("users")
              .document(uidList.elementAt(i))
              .collection("chores")
              .add({
            'task': chore.task,
            'date': chore.date,
            'time': chore.time,
            'status': chore.status,
            'rpt': chore.rpt,
            'assignment': chore.assignment
          });
        }
      }
    }
    return chore.choreID;
    //return retVal;
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
        'assignment': chore.assignment
      });

      retVal = "success";
      //return choreID;
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  Future<String> completeChore(Task chore, String groupId) async {
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
        'assignment': chore.assignment
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
    } catch (e) {
      print(e);
    }

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
      print("chore trying to delete id:" + choreID);
      retVal = "success";
    } catch (e) {
      print("error deleting");
      print(e);
    }

    return retVal;
  }

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
      print("Here is what isn't working.");
      print(e);
    }

    return choreList;
  }

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

  //get the chore list to display
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
      print("Here is what isn't working.");
      print(e);
    }

    return choreList;
  }

  Future<List<Task>> determineChoreList(
      String value, String groupID, String uid) async {
    List<Task> retList = List();
    print("dropdownValue:" + value);
    if (value.compareTo("My Chores") == 0) {
      retList = await getUserChoreList(uid);
    } else {
      retList = await getChoreList(groupID);
      print(retList);
    }
    return retList;
  }

  Future<List<Map<String, dynamic>>> getUserChoreMapList(String uid) async {
    final QuerySnapshot result = await _firestore
        .collection("users")
        .document(uid)
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
  Future<List<Task>> getUserChoreList(String uid) async {
    List<Task> choreList = List<Task>();

    try {
      //THIS DOESN'T WORK FOR SOME REASON
      var choreMapList =
          await getUserChoreMapList(uid); //Get Map List from database
      int count = choreMapList.length;

      //For loop to create Task List from a Map List
      for (int i = 0; i < count; i++) {
        choreList.add(Task.fromMapObject(choreMapList[i]));
        //choreList[i].
      }
    } catch (e) {
      print(e);
    }

    return choreList;
  }

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

  Future<String> createNotifications(
      List<String> tokens, String bookName, String author) async {
    String retVal = "error";

    try {
      await _firestore.collection("notifications").add({
        'bookName': bookName.trim(),
        'author': author.trim(),
        'tokens': tokens,
      });
      retVal = "success";
    } catch (e) {
      print(e);
    }

    return retVal;
  }

  // Future<List<BookModel>> getBookHistory(String groupId) async {
  //   List<BookModel> retVal = List();

  //   try {
  //     QuerySnapshot query = await _firestore
  //         .collection("groups")
  //         .document(groupId)
  //         .collection("books")
  //         .orderBy("dateCompleted", descending: true)
  //         .getDocuments();

  //     query.documents.forEach((element) {
  //       retVal.add(BookModel.fromDocumentSnapshot(doc: element));
  //     });
  //   } catch (e) {
  //     print(e);
  //   }
  //   return retVal;
  // }

//   Future<List<ReviewModel>> getReviewHistory(
//       String groupId, String bookId) async {
//     List<ReviewModel> retVal = List();

//     try {
//       QuerySnapshot query = await _firestore
//           .collection("groups")
//           .document(groupId)
//           .collection("books")
//           .document(bookId)
//           .collection("reviews")
//           .getDocuments();

//       query.documents.forEach((element) {
//         retVal.add(ReviewModel.fromDocumentSnapshot(doc: element));
//       });
//     } catch (e) {
//       print(e);
//     }
//     return retVal;
//   }
// }
}
