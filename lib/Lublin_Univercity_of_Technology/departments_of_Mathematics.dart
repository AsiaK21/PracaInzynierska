import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projekt_inzynierski/chats/chats.dart';
import 'package:projekt_inzynierski/univercity_chat/univercity_chat_screen.dart';
import '../services/firebase_firestore_univercity_service.dart';

class MathematicsSelectionScreen extends StatefulWidget {
  @override
  _MathematicsSelectionScreen createState() => _MathematicsSelectionScreen();
}

class _MathematicsSelectionScreen extends State<MathematicsSelectionScreen> {
  List<String> departmentsofMathematics = [
    'Katedra Inteligencji Obliczeniowej',
    'Katedra Informatyki Stosowanej',
    'Katedra Informatyki Technicznej',
    'Katedra Matematyki Stosowanej',
    'Katedra Metod i Technik Nauczania'
  ];

  String selectedDepartment = '';

  void selectDepartment(String department) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userEmail = user.email;

      final userData = {
        'selectedDepartment': department,
      };

      final groupId = 'department_$department';

      await FirebaseFirestoreUnivercityService().addUserToGroup(groupId, userEmail!);

      switch (department) {
        case 'Katedra Inteligencji Obliczeniowej':
        case 'Katedra Informatyki Stosowanej':
        case 'Katedra Informatyki Technicznej':
        case 'Katedra Matematyki Stosowanej':
        case 'Katedra Metod i Technik Nauczania':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const ChatsScreen(),
            ),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UnivercityChatScreen(),
            ),
          );
          break;
        default:
          print('Wybrana katedra nie jest rozpoznawana.');
          break;
      }
    } else {
      print('Użytkownik nie jest uwierzytelniony.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Witaj na której jesteś katedrze?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16.0),
                Column(
                  children: departmentsofMathematics.map((department) {
                    return Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedDepartment = department;
                            });
                            selectDepartment(department);
                          },
                          style: ElevatedButton.styleFrom(
                            primary: selectedDepartment == department ? Colors.purpleAccent : null,
                            padding: const EdgeInsets.all(16.0),
                          ),
                          child: DefaultTextStyle(
                            style: TextStyle(
                              color: selectedDepartment == department ? Colors.white : Colors.black,
                              fontSize: 16,
                            ),
                            child: Text(department),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}