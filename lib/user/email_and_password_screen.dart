import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Lublin_University_of_Technology/faculty_selection_screen.dart';
import '../chats/chats.dart';

class EmailAndPasswordScreen extends StatelessWidget {
  final bool isRegistration;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  EmailAndPasswordScreen({required this.isRegistration});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildRoundedTextField('E-mail', emailController),
                const SizedBox(height: 16),
                _buildRoundedTextField('Hasło', passwordController, isObscure: true),
                if (isRegistration)
                  Column(
                    children: [
                      const SizedBox(height: 16),
                      _buildRoundedTextField(
                        'Powtórz hasło',
                        confirmPasswordController,
                        isObscure: true,
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                _buildRoundedButton(
                  onPressed: () async {
                    final email = emailController.text;
                    final password = passwordController.text;
                    final confirmPassword = confirmPasswordController.text;

                    if (isRegistration) {
                      if (password != confirmPassword) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Hasła nie są identyczne'),
                          ),
                        );
                        return;
                      }

                      if (email.endsWith('@pollub.edu.pl')) {
                        try {
                          await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
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
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Adres e-mail musi należeć do domeny @pollub.edu.pl'),
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
                      }
                    }
                  },
                  child: isRegistration
                      ? const Text('Zarejestruj się')
                      : const Text('Zaloguj się'),
                ),
              ],
            ),
          ),
        )
    );
  }

  Widget _buildRoundedTextField(String label, TextEditingController controller, {bool isObscure = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isObscure,
        decoration: InputDecoration(
          hintText: label,
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildRoundedButton({required VoidCallback onPressed, required Widget child}) {
    return Container(
      width: 200,
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ElevatedButton(
        onPressed: onPressed,
        child: child,
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ),
    );
  }
}