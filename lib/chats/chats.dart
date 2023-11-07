import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../forum_chat/forum_chat_screen.dart';
import '../private_chat_screen/private_chat_screen.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({Key? key}) : super(key: key);

  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        automaticallyImplyLeading: false, // Blokuje przycisk wstecz
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  // Przenosimy się do ekranu forum_chat_screen.dart
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ForumChatScreen(),
                    ),
                  );
                },
                child: const Text('Forum', style: TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              width: 200,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  // Przenosimy się do ekranu private_chat_screen.dart
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrivateChatScreen(),
                    ),
                  );
                },
                child: const Text('Prywatny', style: TextStyle(fontSize: 20)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
