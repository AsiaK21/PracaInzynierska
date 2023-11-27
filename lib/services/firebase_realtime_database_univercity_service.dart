import 'package:firebase_database/firebase_database.dart';
import 'package:projekt_inzynierski/models/chat_message.dart';

class FirebaseRealtimeGroupsService {
  static final FirebaseDatabase database = FirebaseDatabase.instance;
  static DatabaseReference groupChatReference = database.ref().child('univercity_chat');

  static Future<void> sendGroupMessage(String sender, String group, String message, String groupId) async {
    final groupChatMessageRef = groupChatReference.child(groupId).push();
    await groupChatMessageRef.set({
      'id': groupChatMessageRef.key,
      'sender': sender,
      'group': group,
      'message': message,
      'groupId': groupId,
      'timestamp': DateTime.now().toUtc().millisecondsSinceEpoch,
    });
  }

  Stream<List<ChatMessage>> getGroupChatMessagesStream(String groupId) {
    if (groupId.isNotEmpty) {
      DatabaseReference groupChatMessagesRef = groupChatReference.child(groupId);
      return groupChatMessagesRef.onValue.map((event) {
        List<ChatMessage> messages = [];
        if (event.snapshot.value != null) {
          Map<String,dynamic>.from(event.snapshot.value as dynamic).forEach((key, value) {
            messages.add(ChatMessage.fromSnapshot(event.snapshot.child(key)));
          });
        }
        messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        return messages;
      });
    } else {
      return Stream.value([]);
    }
  }

  Future<void> deleteGroupChatMessages(String groupId) async {
    try {
      DatabaseReference groupChatMessagesRef = groupChatReference.child(groupId);
      await groupChatMessagesRef.remove();
      print('Group chat messages deleted successfully');
    } catch (error) {
      print('Error deleting group chat messages: $error');
    }
  }
}