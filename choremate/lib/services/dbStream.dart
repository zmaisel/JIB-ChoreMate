import 'package:choremate/models/groupModel.dart';
import 'package:choremate/models/userModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DBStream {
  Firestore _firestore = Firestore.instance;

  Stream<UserModel> getCurrentUser(String uid) {
    return _firestore
        .collection('users')
        .document(uid)
        .snapshots()
        .map((docSnapshot) => UserModel.fromDocumentSnapshot(doc: docSnapshot));
  }

  Stream<GroupModel> getCurrentGroup(String groupId) {
    return _firestore.collection('groups').document(groupId).snapshots().map(
        (docSnapshot) => GroupModel.fromDocumentSnapshot(doc: docSnapshot));
  }
}
