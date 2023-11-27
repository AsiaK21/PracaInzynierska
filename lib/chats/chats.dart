import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test/expect.dart';
import '../forum_chat/forum_chat_screen.dart';
import '../private_chat_screen/private_chat_screen.dart';
import '../univercity_chat/univercity_chat_screen.dart';
import '../user/email_and_password_screen.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({Key? key}) : super(key: key);

  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  String oldPassword = '';
  String newPassword = '';
  String repeatNewPassword = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.vpn_key),
            onPressed: () {
              _showChangePasswordDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => EmailAndPasswordScreen(isRegistration: false),
                ),
              );
            },
          ),
        ],
        automaticallyImplyLeading: false,
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
            const SizedBox(height: 16.0),
            SizedBox(
              width: 200,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UnivercityChatScreen(),
                    ),
                  );
                },
                child: const Text('Uczelnia', style: TextStyle(fontSize: 20)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Zmień hasło'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                onChanged: (value) {
                  oldPassword = value;
                },
                decoration: const InputDecoration(
                  labelText: 'Stare hasło',
                ),
                obscureText: true,
              ),
              TextFormField(
                onChanged: (value) {
                  newPassword = value;
                },
                decoration: const InputDecoration(
                  labelText: 'Nowe hasło',
                ),
                obscureText: true,
              ),
              TextFormField(
                onChanged: (value) {
                  repeatNewPassword = value;
                },
                decoration: const InputDecoration(
                  labelText: 'Powtórz nowe hasło',
                ),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _changePassword(oldPassword, newPassword, repeatNewPassword);
                Navigator.pop(context);
              },
              child: const Text('Zmień hasło'),
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

  void _changePassword(String oldPassword, String newPassword, String repeatNewPassword) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: FirebaseAuth.instance.currentUser!.email!,
        password: oldPassword,
      );

      if (newPassword == repeatNewPassword) {
        await userCredential.user!.updatePassword(newPassword);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hasło zostało zmienione'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nowe hasło i powtórzone nowe hasło są różne'),
          ),
        );
      }
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nie udało się zmienić hasła'),
        ),
      );
    }
  }
}
