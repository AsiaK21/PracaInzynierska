import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:projekt_inzynierski/models/group.dart';

import 'firebase_realtime_database_groups_service.dart';

class FirebaseFirestoreGroupsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//nieużywana funkcja pobierająca grupy stworzone przez uzytkownika
  Future<List<Group>> getUserOwnedGroups(String userEmail) async {
    try {
      DocumentSnapshot userSnapshot =
      await _firestore.collection('users').doc(userEmail).get();

      if (userSnapshot.exists) {
        List<dynamic> groupIds = userSnapshot['groups'];
        print(groupIds);
        List<Group> ownedGroups = [];

        for (String groupId in groupIds) {
          DocumentSnapshot groupSnapshot =
          await _firestore.collection('groups').doc(groupId).get();
          if (groupSnapshot.exists) {
            ownedGroups.add(Group(id: groupSnapshot['id'], name: groupSnapshot['name'], participants: []));
            // ownedGroupNames.add(groupSnapshot['name']);
          }
        }

        return ownedGroups;
      } else {
        print('User not found');
        return [];
      }
    } catch (error) {
      print('Error getting user owned groups: $error');
      return [];
    }
  }

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
      print('Error getting user joined groups: $error');
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


      print('Group created successfully');
    } catch (error) {
      print('Error creating group: $error');
    }
  }

  // Funkcja do tworzenia grupy
  Future<void> createGroupWithParticipants(String groupName, List<String> participants) async {
    try {
      String groupId = const Uuid().v4(); // Generate UUID
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
      print('Group created successfully');
    } catch (error) {
      print('Error creating group: $error');
    }
  }

  Future<void> addUserToGroup(String groupId, String email) async {
    _firestore.collection('groups').where('id', isEqualTo: groupId).get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.update({
          'participants': FieldValue.arrayUnion([email])
        });
        print('User added successfully to the group');
      }
    })
        .catchError((error) {
      print('Error adding user to group: $error');
    });
  }

  Future<void> removeUserFromGroup(String groupId, String email) async {
    _firestore.collection('groups').where('id', isEqualTo: groupId).get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.update({
          'participants': FieldValue.arrayRemove([email])
        });
        print('User removed successfully from the group');
      }
    })
        .catchError((error) {
      print('Error removing user from group: $error');
    });
  }
  // Future<void> deleteGroup(String groupId) async {
  //   try {
  //     await FirebaseRealtimeGroupsService().deleteGroupChatMessages(groupId);
  //
  //     QuerySnapshot groupSnapshot = await _firestore
  //         .collection('groups')
  //         .where('id', isEqualTo: groupId)
  //         .get();
  //
  //     groupSnapshot.docs.forEach( (e) async => {
  //       await _firestore.collection("groups").doc(e.id).delete()
  //     });
  //
  //     QuerySnapshot usersWithGroup =
  //     await _firestore.collection('users').where('groups', arrayContains: groupId).get();
  //
  //     for (QueryDocumentSnapshot userDoc in usersWithGroup.docs) {
  //       DocumentReference userRef = _firestore.collection('users').doc(userDoc.id);
  //
  //       DocumentReference subcollectionRef = userRef.collection('groups').doc(groupId);
  //
  //       await subcollectionRef.delete();
  //
  //       await userRef.update({
  //         'groups': FieldValue.arrayRemove([groupId]),
  //       });
  //     }
  //
  //     print('Group deleted successfully');
  //   } catch (error) {
  //     print('Error deleting group: $error');
  //   }
  // }
  Future<void> deleteGroup(String groupId) async {
    try {
      if (groupId.startsWith('faculty_')) {
        print('Nie można usunąć grupy z przedrostkiem "faculty_".');
        return;
      }

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

      print('Grupa została pomyślnie usunięta.');
    } catch (error) {
      print('Błąd podczas usuwania grupy: $error');
    }
  }



}
