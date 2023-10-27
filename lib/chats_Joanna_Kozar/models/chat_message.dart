import 'package:firebase_database/firebase_database.dart';

class ChatMessage {
  String id;
  String sender;
  String receiver;
  String message;
  String groupId;
  int timestamp;

  ChatMessage(this.id, this.sender, this.receiver, this.message, this.groupId, this.timestamp);

  factory ChatMessage.fromSnapshot(DataSnapshot snapshot) {
    Map<String, dynamic>? data = Map<String,dynamic>.from(snapshot.value as dynamic);
    return ChatMessage(
      snapshot.key!,
      data?['sender'] ?? '',
      data?['receiver'] ?? '',
      data?['message'] ?? '',
      data?['groupId'] ?? '',
      data?['timestamp'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sender': sender,
      'receiver': receiver,
      'message': message,
      'groupId': groupId,
      'timestamp': timestamp,
    };
  }
}