import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:projekt_inzynierski/models/chat.dart';

import 'firebase_realtime_database_private_chats_service.dart';


class FirebaseFirestoreGroupsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Chat>> getUserOwnedChats(String userEmail) async {
    try {
      DocumentSnapshot userSnapshot =
      await _firestore.collection('users').doc(userEmail).get();

      if (userSnapshot.exists) {
        List<dynamic> chatIds = userSnapshot['chats'];
        List<Chat> ownedChats = [];

        for (String chatId in chatIds) {
          DocumentSnapshot chatSnapshot =
          await _firestore.collection('chats').doc(chatId).get();
          if (chatSnapshot.exists) {
            ownedChats.add(Chat(id: chatSnapshot['id'], name: chatSnapshot['name'], participants: []));
          }
        }

        return ownedChats;
      } else {
        return [];
      }
    } catch (error) {
      return [];
    }
  }

  Future<List<Chat>> getUserJoinedChats(String userEmail) async {
    try {
      QuerySnapshot groupSnapshot = await _firestore
          .collection('chats')
          .where('participants', arrayContains: userEmail)
          .get();

      List<Chat> joinedChatNames = [];

      for (QueryDocumentSnapshot doc in groupSnapshot.docs) {
        if (doc.exists) {
          joinedChatNames.add(Chat(id: doc['id'], name: doc['name'], participants: []));
        }
      }

      return joinedChatNames;
    } catch (error) {
      return [];
    }
  }

  Future<void> createChat(String id, String chatName, List<String> participants) async {
    try {
      DocumentReference chatRef = await _firestore.collection('chats').add({
        'id': id,
        'name': chatName,
        'participants': participants,
      });

      for (String email in participants) {
        DocumentReference userRef = _firestore.collection('users').doc(email);

        await userRef.update({
          'chats': FieldValue.arrayUnion([id]),
        });
      }
    } catch (error) {
    }
  }

  Future<void> createChatWithParticipants(String chatName, List<String> participants) async {
    try {
      String chatId = const Uuid().v4();
      DocumentReference chatRef =
      await _firestore.collection('chats').add({
        'id': chatId,
        'name': chatName,
        'participants': participants,
      });

      int memberId = 1;
      for (String email in participants) {
        DocumentReference userRef = _firestore.collection('users').doc(email);

        await userRef.update({
          'chats': FieldValue.arrayUnion([chatId]),
          'chat_member_id': memberId,
        });

        memberId++;
      }
    } catch (error) {
    }
  }

  Future<void> addUserToChat(String chatId, String email) async {
    _firestore.collection('chats').where('id', isEqualTo: chatId).get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.update({
          'participants': FieldValue.arrayUnion([email])
        });
      });
    })
        .catchError((error) {
    });
  }

  Future<void> deleteChat(String chatId) async {
    try {
      await FirebaseRealtimePrivateService().deletePrivateChatMessages(chatId);

      QuerySnapshot chatSnapshot = await _firestore
          .collection('chats')
          .where('id', isEqualTo: chatId)
          .get();

      chatSnapshot.docs.forEach( (e) async => {
        await _firestore.collection("chats").doc(e.id).delete()
      });

      QuerySnapshot usersWithChats =
      await _firestore.collection('users').where('chats', arrayContains: chatId).get();

      for (QueryDocumentSnapshot userDoc in usersWithChats.docs) {
        DocumentReference userRef = _firestore.collection('users').doc(userDoc.id);

        DocumentReference subcollectionRef = userRef.collection('chats').doc(chatId);

        await subcollectionRef.delete();

        await userRef.update({
          'chats': FieldValue.arrayRemove([chatId]),
        });
      }
    } catch (error) {
    }
  }
}