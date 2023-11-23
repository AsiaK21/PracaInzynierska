import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projekt_inzynierski/chats/chats.dart';
import 'package:projekt_inzynierski/univercity_chat/univercity_chat_screen.dart';
import '../services/firebase_firestore_univercity_service.dart';

class ManagementsSelectionScreen extends StatefulWidget {
  @override
  _ManagementsSelectionScreen createState() => _ManagementsSelectionScreen();
}

class _ManagementsSelectionScreen extends State<ManagementsSelectionScreen> {
  List<String> departmentsofManagements = [
    'Katedra Ekonomii i Zarządzania Gospodarką',
    'Katedra Finansów i Rachunkowości',
    'Katedra Inżynierii Systemów Informacyjnych',
    'Katedra Marketingu',
    'Katedra Metod Ilościowych w Zarządzaniu',
    'Katedra Organizacji Przedsiębiorstwa',
    'Katedra Strategii i Projektowania Biznesu',
    'Katedra Zarządzania'
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
        case 'Katedra Ekonomii i Zarządzania Gospodarką':
        case 'Katedra Finansów i Rachunkowości':
        case 'Katedra Inżynierii Systemów Informacyjnych':
        case 'Katedra Marketingu':
        case 'Katedra Metod Ilościowych w Zarządzaniu':
        case 'Katedra Organizacji Przedsiębiorstwa':
        case 'Katedra Strategii i Projektowania Biznesu':
        case 'Katedra Zarządzania':
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
                  children: departmentsofManagements.map((department) {
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
