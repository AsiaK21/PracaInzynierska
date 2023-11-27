import 'package:firebase_database/firebase_database.dart';
import 'package:projekt_inzynierski/models/chat_message.dart';

class FirebaseRealtimePrivateService {
  static final FirebaseDatabase database = FirebaseDatabase.instance;
  static DatabaseReference privateChatReference = database.ref().child('private_chat');

  static Future<void> sendPrivateMessage(String sender, String chat, String message, String chatId) async {
    final privateChatMessageRef = privateChatReference.child(chatId).push();
    await privateChatMessageRef.set({
      'id': privateChatMessageRef.key,
      'sender': sender,
      'chat': chat,
      'message': message,
      'chatId': chatId,
      'timestamp': DateTime.now().toUtc().millisecondsSinceEpoch,
    });
  }

  Stream<List<ChatMessage>> getPrivateChatMessagesStream(String chatId) {
    if (chatId.isNotEmpty) {
      DatabaseReference privateChatMessagesRef = privateChatReference.child(chatId);
      return privateChatMessagesRef.onValue.map((event) {
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

  Future<void> deletePrivateChatMessages(String chatId) async {
    try {
      DatabaseReference privateChatMessagesRef = privateChatReference.child(chatId);
      await privateChatMessagesRef.remove();
      print('Group chat messages deleted successfully');
    } catch (error) {
      print('Error deleting group chat messages: $error');
    }
  }
}