import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projekt_inzynierski/chats_Joanna_Kozar/services/auth_service.dart';

import 'package:projekt_inzynierski/chats_Joanna_Kozar/models/chat_message.dart';
import 'package:projekt_inzynierski/chats_Joanna_Kozar/models/chat.dart';

import 'package:uuid/uuid.dart';

import 'package:projekt_inzynierski/chats_Joanna_Kozar/services/firebase_firestore_private_chats_service.dart';
import 'package:projekt_inzynierski/chats_Joanna_Kozar/services/firebase_realtime_database_private_chats_service.dart';


class PrivateChatScreen extends StatefulWidget {
  final MaterialColor bordowyKolor;

  const PrivateChatScreen({Key? key, required this.bordowyKolor}) : super(key: key);

  @override
  _PrivateChatScreenState createState() => _PrivateChatScreenState();
}

class _PrivateChatScreenState extends State<PrivateChatScreen> {
  List<Chat> chats = [];
  Chat selectedChat = Chat(id: '', name: '', participants: []);
  String addUserEmail = '';
  String removeUserEmail = '';
  TextEditingController messageController = TextEditingController();
  TextEditingController chatNameController = TextEditingController();
  bool isGroupListExpanded = true;
  bool isRightGroupListExpanded = true;
  FirebaseFirestoreGroupsService firestoreService = FirebaseFirestoreGroupsService();
  FirebaseRealtimePrivateService realtimeService = FirebaseRealtimePrivateService();
  AuthService authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((user) {
      setState(() {
        currentUser = user;
      });
      _loadUserChats(user);
    });
  }

  void _loadUserChats(User? user) async {
    if (user != null) {
      List<Chat> userChats = await firestoreService.getUserJoinedChats(user.email!);

      setState(() {
        chats = userChats;
      });
    }
  }

  void _createChat() async {
    String chatName = chatNameController.text;
    String secondParticipant = addUserEmail;
    if (chatName.isNotEmpty) {
      List<String> participants = [currentUser!.email!,secondParticipant];
      String chatId = const Uuid().v4();
      await firestoreService.createChat(chatId, chatName, participants);
      _loadUserChats(currentUser);
      chatNameController.clear();
    }
  }

  // void _addUserToChat(String chatId, String email) {
  //   if (chatId.isNotEmpty && email.isNotEmpty) {
  //     firestoreService.addUserToChat(chatId, email);
  //   }
  // }

  void _toggleGroupList() {
    setState(() {
      isGroupListExpanded = !isGroupListExpanded;
    });
  }

  void _toggleRightGroupList() {
    setState(() {
      isRightGroupListExpanded = !isRightGroupListExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Opacity(
              opacity: 0.5,
              child: IconButton(
                onPressed: _toggleGroupList,
                icon: Icon(
                  isGroupListExpanded ? Icons.arrow_back : Icons.list_alt,
                ),
              ),
            ),
            Text(
              selectedChat.name,
              style: const TextStyle(fontSize: 18.0),
            ),
            Opacity(
              opacity: 0.5,
              child: IconButton(
                onPressed: _toggleRightGroupList,
                icon: Icon(
                  isRightGroupListExpanded ? Icons.arrow_forward : Icons
                      .settings,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Row(
        children: [
          // Left sidebar with groups
          AnimatedContainer(
            width: isGroupListExpanded ? 140.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: isGroupListExpanded
                ? Container(
              color: Colors.grey[200],
              child: ListView.builder(
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final Chat chat = chats[index];

                  final bool isSelected = chat.id == selectedChat.id;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedChat = chat;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 1.0),
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? widget.bordowyKolor.withOpacity(0.5)
                            : Colors.white,
                        border: Border.all(color: Colors.black),
                      ),
                      child: Text(
                        chat.name,
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
                : null,
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: StreamBuilder<List<ChatMessage>>(
                    stream: realtimeService.getPrivateChatMessagesStream(
                      selectedChat.id,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasData) {
                        List<ChatMessage> messages = snapshot.data!;
                        return ListView.builder(
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final ChatMessage message = messages[index];
                            final isCurrentUser =
                                message.sender == currentUser!.email;
                            final messageContent = message.message;

                            return Container(
                              alignment: isCurrentUser
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 4.0,
                              ),
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: isCurrentUser
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    alignment: isCurrentUser
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    padding: const EdgeInsets.only(
                                      bottom: 4.0,
                                    ),
                                    child: Text(
                                      isCurrentUser ? 'Ty' : message.sender,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: isCurrentUser
                                          ? Colors.white
                                          : widget.bordowyKolor.withOpacity(
                                        0.5,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        8.0,
                                      ),
                                      border: Border.all(
                                        color: widget.bordowyKolor,
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      messageContent,
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      } else {
                        return const Center(
                          child: Text('Brak wiadomości.'),
                        );
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: messageController,
                          onEditingComplete: () {
                            String message = messageController.text;
                            sendMessage(message, selectedChat.id);
                            messageController.clear();
                          },
                          decoration: InputDecoration(
                            labelText: 'Napisz wiadomość ...',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: widget.bordowyKolor.withOpacity(0.5),
                              ),
                            ),
                            filled: true,
                            fillColor: widget.bordowyKolor.withOpacity(0.5),
                            labelStyle: const TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      ElevatedButton(
                        onPressed: () {
                          String message = messageController.text;
                          sendMessage(message,selectedChat.id);
                          messageController.clear();
                        },
                        child: const Text(
                          'Wyślij',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AnimatedContainer(
            width: isRightGroupListExpanded ? 140.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: isRightGroupListExpanded
                ? Container(
              color: Colors.grey[300],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _showCreateGroupDialog(context);
                    },
                    child: const Text('Utwórz czat'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _showDeleteChatDialog(selectedChat.id);
                    },
                    child: const Text('Usuń czat'),
                  ),
                  if (isRightGroupListExpanded)
                    const SizedBox(height: 20),
                ],
              ),
            )
                : null,
          ),
        ],
      ),
    );
  }

  // sendGroupMessage(String sender, String group, String message, String groupId)
  void sendMessage(String message, String groupId) {
    if (groupId.isNotEmpty && message.isNotEmpty && currentUser != null) {
      FirebaseRealtimePrivateService.sendPrivateMessage(
        currentUser!.email!,
        selectedChat.name,
        message,
        selectedChat.id,
      );
      print(selectedChat.id);
      print(message);
      print(groupId);
    }
  }

  void _showCreateGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Utwórz czat'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: chatNameController,
                decoration: const InputDecoration(
                  labelText: 'Nazwa czatu',
                ),
              ),
              const SizedBox(height: 16.0),
              const Text('Email użytkownika:'),
              TextFormField(
                onChanged: (value) {
                  setState(() {
                    addUserEmail = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Email użytkownika',
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _createChat();
               // _addUserToChat(selectedChat.id, addUserEmail);
                Navigator.pop(context);
              },
              child: const Text('Utwórz czat prywatny z użytkownikiem'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Anuluj'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteChatDialog(String chatId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Potwierdź usunięcie czatu'),
          content: const Text('Czy na pewno chcesz usunąć czat?'),
          actions: [
            TextButton(
              onPressed: () {
                _deleteChat(chatId);
                Navigator.pop(context);
              },
              child: const Text('Tak'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Anuluj'),
            ),
          ],
        );
      },
    );
  }
  void _deleteChat(String chatId) async {
    try {
      // Delete the group using the service
      await firestoreService.deleteChat(chatId);

      setState(() {
        // Remove the group from the local list
        Chat chatToDelete = chats.firstWhere((chat) => chat.id == chatId);
        chats.remove(chatToDelete);
        if (chats.isNotEmpty) {
          selectedChat = chats[0];
        } else {
          selectedChat = Chat(id: '', name: '', participants: []);
        }
      });
    } catch (error) {
      print('Error deleting group: $error');
    }
  }
}
