import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projekt_inzynierski/chats/chats.dart';

import '../Lublin_Univercity_of_Technology/faculty_selection_screen.dart';
import '../Lublin_Univercity_of_Technology/faculty_selection_screen.dart';

class EmailAndPasswordScreen extends StatelessWidget {
  final bool isRegistration;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  EmailAndPasswordScreen({required this.isRegistration});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'E-mail'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Hasło'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text;
                final password = passwordController.text;
                if (isRegistration) {
                  if (email.endsWith('@pollub.edu.pl')) {
                    try {
                      await FirebaseAuth.instance.createUserWithEmailAndPassword(
                        email: email,
                        password: password,
                      );
                     Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FacultySelectionScreen(),
                       ),
                     );
                    } catch (e) {
                      print(e.toString());
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Adres e-mail musi należeć do domeny @pollub.edu.pl'),
                      ),
                    );
                  }
                } else {
                  try {
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: email,
                      password: password,
                    );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChatsScreen(),
                      ),
                    );
                  } catch (e) {
                    // Obsługa błędów logowania
                    print(e.toString());
                  }
                }
              },
              child: isRegistration ? const Text('Zarejestruj się') : const Text('Zaloguj się'),
            ),
          ],
        ),
      ),
    );
  }
}
