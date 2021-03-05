import 'package:choremate/models/task.dart';
//import 'package:choremate/models/reviewModel.dart';
import 'package:choremate/models/userModel.dart';
import 'package:choremate/states/currentUser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:choremate/models/choreModel.dart';

class DBFuture {
  Firestore _firestore = Firestore.instance;

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
        //'groupName': groupName.trim(),
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

  Future<String> addChore(String groupId, ChoreModel chore) async {
    String retVal = "error";

    try {
      DocumentReference _docRef = await _firestore
          .collection("groups")
          .document(groupId)
          .collection("chores")
          .add({
        'name': chore.name.trim(),
        'dueDate': chore.dueDate,
        'dueTime': chore.dueTime,
        'status': chore.status,
        'uid': chore.uid,
        'groupId': chore.groupId,
        'repeating': chore.repeating,
      });

      //add current book to group schedule
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

  Future<String> deleteChore(String groupId, ChoreModel chore) async {
    String retVal = "error";
    try {
      await _firestore
          .collection("groups")
          .document(groupId)
          .collection("chores")
          .document(chore.choreId)
          .delete();

      //add current book to group schedule
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

  //CURRENTLY WORKING ON 
  // trying to get a map of the chores in the database to be able to display in the UI 

  Future<List<Map<String, dynamic>>> getChoreMapList(String groupId) async {
    //List<String> retList = List();

    try {
      await _firestore.collection("groups").document(groupId).get().addOnCompleteListener(task -> {
    if (task.isSuccessful()) {
        DocumentSnapshot document = task.getResult();
        if (document.exists()) {
            List<Map<String, Object>> users = (List<Map<String, Object>>) document.get("users");
        }
    }
});
    } catch (e) {
      print(e);
    }
    return retList;
  }

  Future<List<ChoreModel>> getChoreList() {}

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
}
