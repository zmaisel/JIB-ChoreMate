import 'package:choremate/models/task.dart';
//import 'package:choremate/models/reviewModel.dart';
import 'package:choremate/models/userModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:choremate/models/message.dart';

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
    List<String> tokens = List();

    try {
      members.add(user.uid);
      tokens.add(user.notifToken);
      DocumentReference _docRef;
      if (user.notifToken != null) {
        print("made it here!");
        _docRef = await _firestore.collection("groups").add({
          'name': groupName.trim(),
          'leader': user.uid,
          'members': members,
          'tokens': tokens,
          'groupCreated': Timestamp.now(),
        });
      } else {
        _docRef = await _firestore.collection("groups").add({
          'name': groupName.trim(),
          'leader': user.uid,
          'members': members,
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
    try {
      members.add(userModel.uid);
      //tokens.add(userModel.notifToken);
      await _firestore.collection("groups").document(groupId).updateData({
        'members': FieldValue.arrayUnion(members),
        //'tokens': FieldValue.arrayUnion(tokens),
      });

      await _firestore.collection("users").document(userModel.uid).updateData({
        'groupId': groupId.trim(),
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
    try {
      members.add(userModel.uid);
      //tokens.add(userModel.notifToken);
      await _firestore.collection("groups").document(groupId).updateData({
        'members': FieldValue.arrayRemove(members),
        'tokens': FieldValue.arrayRemove(tokens),
      });

      await _firestore.collection("users").document(userModel.uid).updateData({
        'groupId': null,
      });
    } catch (e) {
      print(e);
    }

    return retVal;
  }

  Future<String> addChore(String groupId, String name, String date, String time,
      String status, String rpt, String assignment) async {
    String retVal = "error";

    try {
      DocumentReference _docRef = await _firestore
          .collection("groups")
          .document(groupId)
          .collection("chores")
          .add({
        'choreID': "",
        'task': name,
        'date': date,
        'time': time,
        'status': status,
        'rpt': rpt,
        'assignment': assignment
      });
      DocumentSnapshot docSnap = await _docRef.get();

      print(docSnap.reference.documentID.toString());
      String choreID = docSnap.reference.documentID.toString();
      // //add current book to group schedule
      // await _firestore.collection("groups").document(groupId).updateData({
      //   "currentBookId": _docRef.documentID,
      //   "currentBookDue": chore.time,
      // });

      retVal = "success";
      updateChore(choreID, groupId, name, date, time, status, rpt, assignment);
      return choreID;
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  Future<String> updateChore(
      String choreID,
      String groupId,
      String name,
      String date,
      String time,
      String status,
      String rpt,
      String assignment) async {
    String retVal = "error";
    try {
      await _firestore
          .collection("groups")
          .document(groupId)
          .collection("chores")
          .document(choreID)
          .updateData({
        'choreID': choreID,
        'task': name,
        'date': date,
        'time': time,
        'status': status,
        'rpt': rpt,
        'assignment': assignment
      });

      // //add current book to group schedule
      // await _firestore.collection("groups").document(groupId).updateData({
      //   "currentBookId": _docRef.documentID,
      //   "currentBookDue": chore.time,
      // });

      retVal = "success";
    } catch (e) {
      print(e);
    }

    return retVal;
  }

  Future<String> completeChore(
      String choreID,
      String groupId,
      String name,
      String date,
      String time,
      String status,
      String rpt,
      String assignment) async {
    String retVal = "error";
    //first add the chore to to completed collection
    try {
      await _firestore
          .collection("groups")
          .document(groupId)
          .collection("completedChores")
          .add({
        'choreID': choreID,
        'task': name,
        'date': date,
        'time': time,
        'status': status,
        'rpt': rpt,
        'assignment': assignment
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
          .document(choreID)
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
      retVal = "success";
    } catch (e) {
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
      //THIS DOESN'T WORK FOR SOME REASON
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

  Future<String> addNextBook(String groupId, Task chore) async {
    String retVal = "error";

    try {
      DocumentReference _docRef = await _firestore
          .collection("groups")
          .document(groupId)
          .collection("books")
          .add({
        'name': chore.task.trim(),
        'author': chore.assignment.trim(),
        'length': chore.time,
        'dateCompleted': chore.date,
      });

      //add current book to group schedule
      await _firestore.collection("groups").document(groupId).updateData({
        "nextBookId": _docRef.documentID,
        "nextBookDue": chore.date,
      });

      //adding a notification document
      DocumentSnapshot doc =
          await _firestore.collection("groups").document(groupId).get();
      createNotifications(List<String>.from(doc.data["tokens"]) ?? [],
          chore.task, chore.assignment);

      retVal = "success";
    } catch (e) {
      print(e);
    }

    return retVal;
  }

  //REMINDERS

  Future<String> addReminder(String groupId, String name) async {
    String retVal = "error";

    try {
      DocumentReference _docRef2 = await _firestore
          .collection("groups")
          .document(groupId)
          .collection("reminders")
          .add({
        'messageID': "",
        'message': name 
      });
      DocumentSnapshot docSnap = await _docRef2.get();

      print(docSnap.reference.documentID.toString());
      String messageID = docSnap.reference.documentID.toString();

      retVal = "success";
      updateReminder(messageID, groupId, name);
      return messageID;
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  Future<String> updateReminder(
      String messageID,
      String groupId,
      String name) async {
    String retVal = "error";
    try {
      await _firestore
          .collection("groups")
          .document(groupId)
          .collection("reminders")
          .document(messageID)
          .updateData({
        'messageID': messageID,
        'message': name,
      });
      retVal = "success";
    } catch (e) {
      print(e);
    }

    return retVal;
  }


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
  Future<List<Message>> getReminderList(String groupID) async {
    List<Message> reminderList = List<Message>();

    try {
      //THIS DOESN'T WORK FOR SOME REASON
      var reminderMapList =
          await getReminderMapList(groupID); //Get Map List from database
      int count = reminderMapList.length;

      //For loop to create Message List from a Map List
      for (int i = 0; i < count; i++) {
        reminderList.add(Message.fromMapObject(reminderMapList[i]));
      }
    } catch (e) {
      print("Here is what isn't working.");
      print(e);
    }

    return reminderList;
  }

  // Future<String> addCurrentBook(String groupId, BookModel book) async {
  //   String retVal = "error";

  //   try {
  //     DocumentReference _docRef = await _firestore
  //         .collection("groups")
  //         .document(groupId)
  //         .collection("books")
  //         .add({
  //       'name': book.name.trim(),
  //       'author': book.author.trim(),
  //       'length': book.length,
  //       'dateCompleted': book.dateCompleted,
  //     });

  //     //add current book to group schedule
  //     await _firestore.collection("groups").document(groupId).updateData({
  //       "currentBookId": _docRef.documentID,
  //       "currentBookDue": book.dateCompleted,
  //     });

  //     //adding a notification document
  //     DocumentSnapshot doc =
  //         await _firestore.collection("groups").document(groupId).get();
  //     createNotifications(
  //         List<String>.from(doc.data["tokens"]) ?? [], book.name, book.author);

  //     retVal = "success";
  //   } catch (e) {
  //     print(e);
  //   }

  //   return retVal;
  // }

  // Future<BookModel> getCurrentBook(String groupId, String bookId) async {
  //   BookModel retVal;

  //   try {
  //     DocumentSnapshot _docSnapshot = await _firestore
  //         .collection("groups")
  //         .document(groupId)
  //         .collection("books")
  //         .document(bookId)
  //         .get();
  //     retVal = BookModel.fromDocumentSnapshot(doc: _docSnapshot);
  //   } catch (e) {
  //     print(e);
  //   }

  //   return retVal;
  // }

  Future<String> finishedBook(
    String groupId,
    String bookId,
    String uid,
    int rating,
    String review,
  ) async {
    String retVal = "error";
    try {
      await _firestore
          .collection("groups")
          .document(groupId)
          .collection("books")
          .document(bookId)
          .collection("reviews")
          .document(uid)
          .setData({
        'rating': rating,
        'review': review,
      });
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  Future<bool> isUserDoneWithBook(
      String groupId, String bookId, String uid) async {
    bool retVal = false;
    try {
      DocumentSnapshot _docSnapshot = await _firestore
          .collection("groups")
          .document(groupId)
          .collection("books")
          .document(bookId)
          .collection("reviews")
          .document(uid)
          .get();

      if (_docSnapshot.exists) {
        retVal = true;
      }
    } catch (e) {
      print(e);
    }
    return retVal;
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
