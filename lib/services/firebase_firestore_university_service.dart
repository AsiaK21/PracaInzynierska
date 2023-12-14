import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/group.dart';

class FirebaseFirestoreUnivercityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Group>> getUserJoinedGroups(String userEmail) async {
    try {
      QuerySnapshot groupSnapshot = await _firestore
          .collection('univercity')
          .where('participants', arrayContains: userEmail)
          .get();

      List<Group> joinedGroupNames = [];

      for (QueryDocumentSnapshot doc in groupSnapshot.docs) {
        if (doc.exists) {
          joinedGroupNames.add(Group(id: doc['id'], name: doc['name'], participants: []));
        }
      }

      return joinedGroupNames;
    } catch (error) {
      return [];
    }
  }

  Future<void> addUserToGroup(String groupId, String email) async {
    _firestore.collection('univercity').where('id', isEqualTo: groupId).get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.update({
          'participants': FieldValue.arrayUnion([email])
        });
      }
    })
        .catchError((error) {
    });
  }
  Future<void> removeUserFromGroup(String groupId, String email) async {
    _firestore.collection('univercity').where('id', isEqualTo: groupId).get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.update({
          'participants': FieldValue.arrayRemove([email])
        });
      }
    })
        .catchError((error) {
    });
  }
}