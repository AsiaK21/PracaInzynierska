import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projekt_inzynierski/services/auth_service.dart';

import 'package:projekt_inzynierski/models/chat_message.dart';
import 'package:projekt_inzynierski/models/group.dart';

import 'package:uuid/uuid.dart';

import 'package:projekt_inzynierski/services/firebase_firestore_groups_service.dart';
import 'package:projekt_inzynierski/services/firebase_realtime_database_groups_service.dart';

class ForumChatScreen extends StatefulWidget {
  const ForumChatScreen({Key? key}) : super(key: key);

  @override
  _ForumChatScreenState createState() => _ForumChatScreenState();
}

class _ForumChatScreenState extends State<ForumChatScreen> {
  List<Group> groups = [];
  Group selectedGroup = Group(id: '', name: '', participants: []);
  String addUserEmail = '';
  String removeUserEmail = '';
  TextEditingController messageController = TextEditingController();
  TextEditingController groupNameController = TextEditingController();
  FirebaseFirestoreGroupsService firestoreService = FirebaseFirestoreGroupsService();
  FirebaseRealtimeGroupsService realtimeService = FirebaseRealtimeGroupsService();
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
      _loadUserGroups(user);
    });
  }

  void _loadUserGroups(User? user) async {
    if (user != null) {
      List<Group> userGroups = await firestoreService.getUserJoinedGroups(user.email!);

      setState(() {
        groups = userGroups;
      });
    }
  }

  void _createGroup() async {
    String groupName = groupNameController.text;
    if (groupName.isNotEmpty) {
      List<String> participants = [currentUser!.email!];
      String groupId = const Uuid().v4();
      await firestoreService.createGroup(groupId, groupName, participants);
      _loadUserGroups(currentUser);
      groupNameController.clear();
    }
  }

  void _addUserToGroup(String groupId, String email) {
    if (groupId.isNotEmpty && email.isNotEmpty) {
      firestoreService.addUserToGroup(groupId, email);
    }
  }

  void _removeUserFromGroup(String groupId, String email) {
    if (groupId.isNotEmpty && email.isNotEmpty) {
      firestoreService.removeUserFromGroup(groupId, email);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                _showLeftPopup(context, groups);
              },
              icon: Icon(
                Icons.list_alt,
              ),
            ),
            Expanded(
              child: Text(
                selectedGroup.name,
                style: const TextStyle(fontSize: 18.0),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              onPressed: () {
                _showRightPopup(context, selectedGroup);
              },
              icon: Icon(
                Icons.more_vert,
              ),
            ),
          ],
        ),
      ),
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: StreamBuilder<List<ChatMessage>>(
                    stream: realtimeService.getGroupChatMessagesStream(
                      selectedGroup.id,
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
                                          : DefaultSelectionStyle.defaultColor.withOpacity(
                                        0.5,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        8.0,
                                      ),
                                      border: Border.all(
                                        color: DefaultSelectionStyle.defaultColor,
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
                            sendMessage(message, selectedGroup.id);
                            messageController.clear();
                          },
                          decoration: InputDecoration(
                            labelText: 'Napisz wiadomość ...',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.purpleAccent,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.purpleAccent.withOpacity(0.5),
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
                          sendMessage(message, selectedGroup.id);
                          messageController.clear();
                        },
                        child: const Text(
                          'Wyślij',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void sendMessage(String message, String groupId) {
    if (groupId.isNotEmpty && message.isNotEmpty && currentUser != null) {
      FirebaseRealtimeGroupsService.sendGroupMessage(
        currentUser!.email!,
        selectedGroup.name,
        message,
        selectedGroup.id,
      );
      print(selectedGroup.id);
      print(message);
      print(groupId);
    }
  }

  void _showCreateGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Utwórz nową grupę'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: groupNameController,
                decoration: const InputDecoration(
                  labelText: 'Nazwa grupy',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _createGroup();
                Navigator.pop(context);
              },
              child: const Text('Utwórz'),
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

  void _showDeleteGroupDialog(String groupId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Potwierdź usunięcie grupy'),
          content: const Text('Czy na pewno chcesz usunąć grupę?'),
          actions: [
            TextButton(
              onPressed: () {
                _deleteGroup(groupId);
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

  void _deleteGroup(String groupId) async {
    try {
      await firestoreService.deleteGroup(groupId);

      setState(() {
        Group groupToDelete = groups.firstWhere((group) => group.id == groupId);
        groups.remove(groupToDelete);
        if (groups.isNotEmpty) {
          selectedGroup = groups[0];
        } else {
          selectedGroup = Group(id: '', name: '', participants: []);
        }
      });
    } catch (error) {
      print('Error deleting group: $error');
    }
  }

  void _showLeftPopup(BuildContext context, List<Group> groups) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          color: Colors.purpleAccent.withOpacity(0.2),
          child: ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final Group group = groups[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedGroup = group;
                    });
                    Navigator.pop(context);
                  },
                  child: Text(
                    group.name,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showRightPopup(BuildContext context, Group selectedGroup) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: Colors.purpleAccent.withOpacity(0.2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showCreateGroupDialog(context);
                  },
                  child: const Text('Utwórz grupę'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showDeleteGroupDialog(selectedGroup.id);
                  },
                  child: const Text('Usuń grupę'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    _showAddUserDialog(context);
                  },
                  child: const Text('Dodaj użytkownika'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    _showRemoveUserDialog(context);
                  },
                  child: const Text('Usuń użytkownika'),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        );
      },
    );
  }

  void _showAddUserDialog(BuildContext context) {
    String email = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Dodaj użytkownika do grupy'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                onChanged: (value) {
                  email = value;
                },
                decoration: const InputDecoration(
                  labelText: 'Email użytkownika',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _addUserToGroup(selectedGroup.id, email);
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Dodaj użytkownika'),
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

  void _showRemoveUserDialog(BuildContext context) {
    String email = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Usuń użytkownika z grupy'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                onChanged: (value) {
                  email = value;
                },
                decoration: const InputDecoration(
                  labelText: 'Email użytkownika',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _removeUserFromGroup(selectedGroup.id, email);
                Navigator.pop(context);
              },
              child: const Text('Usuń użytkownika'),
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
}
