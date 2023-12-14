import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:projekt_inzynierski/models/group.dart';

import 'firebase_realtime_database_groups_service.dart';

class FirebaseFirestoreGroupsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Group>> getUserJoinedGroups(String userEmail) async {
    try {
      QuerySnapshot groupSnapshot = await _firestore
          .collection('groups')
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

  Future<void> createGroup(String id, String groupName, List<String> participants) async {
    try {
      DocumentReference groupRef = await _firestore.collection('groups').add({
        'id': id,
        'name': groupName,
        'participants': participants,
      });

      int memberId = 1;
      for (String email in participants) {
        DocumentReference userRef = _firestore.collection('users').doc(email);

        await userRef.update({
          'groups': FieldValue.arrayUnion([id]),
          'group_member_id': memberId,
        });
        memberId++;
      }
    } catch (error) {
    }
  }

  Future<void> createGroupWithParticipants(String groupName, List<String> participants) async {
    try {
      String groupId = const Uuid().v4();
      DocumentReference groupRef =
      await _firestore.collection('groups').add({
        'id': groupId,
        'name': groupName,
        'participants': participants,
      });

      int memberId = 1;
      for (String email in participants) {
        DocumentReference userRef = _firestore.collection('users').doc(email);

        await userRef.update({
          'groups': FieldValue.arrayUnion([groupId]),
          'group_member_id': memberId,
        });

        memberId++;
      }
    } catch (error) {
    }
  }

  Future<void> addUserToGroup(String groupId, String email) async {
    _firestore.collection('groups').where('id', isEqualTo: groupId).get()
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
    _firestore.collection('groups').where('id', isEqualTo: groupId).get()
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

  Future<void> deleteGroup(String groupId) async {
    try {
      await FirebaseRealtimeGroupsService().deleteGroupChatMessages(groupId);

      QuerySnapshot groupSnapshot = await _firestore
          .collection('groups')
          .where('id', isEqualTo: groupId)
          .get();

      groupSnapshot.docs.forEach((e) async => {
        await _firestore.collection("groups").doc(e.id).delete()
      });

      QuerySnapshot usersWithGroup =
      await _firestore.collection('users').where('groups', arrayContains: groupId).get();

      for (QueryDocumentSnapshot userDoc in usersWithGroup.docs) {
        DocumentReference userRef = _firestore.collection('users').doc(userDoc.id);

        DocumentReference subcollectionRef = userRef.collection('groups').doc(groupId);

        await subcollectionRef.delete();

        await userRef.update({
          'groups': FieldValue.arrayRemove([groupId]),
        });
      }
    } catch (error) {
    }
  }
}
