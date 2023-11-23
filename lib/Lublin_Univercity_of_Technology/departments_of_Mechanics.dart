import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projekt_inzynierski/chats/chats.dart';
import 'package:projekt_inzynierski/univercity_chat/univercity_chat_screen.dart';
import '../services/firebase_firestore_univercity_service.dart';


class MechanicsSelectionScreen extends StatefulWidget {
  @override
  _MechanicsSelectionScreen createState() => _MechanicsSelectionScreen();
}

class _MechanicsSelectionScreen extends State<MechanicsSelectionScreen> {
  List<String> departmentsofMechanics = [
    'Katedra Automatyzacji',
    'Katedra Fizyki Stosowanej',
    'Katedra Informatyzacji i Robotyzacji Produkcji',
    'Katedra Inżynierii Materiałowej',
    'Katedra Mechaniki Stosowanej',
    'Katedra Obróbki Plastycznej Metali',
    'Katedra Podstaw Inżynierii Produkcji',
    'Katedra Podstaw Konstrukcji Maszyn i Mechatroniki',
    'Katedra Pojazdów Samochodowych',
    'Katedra Technologii i Przetwórstwa Tworzyw Polimerowych',
    'Katedra Termodynamiki Mechaniki Płynów i Napędów Lotniczych',
    'Katedra Zrównoważonego Transportu i Żródeł Napędu'
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
        case 'Katedra Automatyzacji':
        case 'Katedra Fizyki Stosowanej':
        case 'Katedra Informatyzacji i Robotyzacji Produkcji':
        case 'Katedra Inżynierii Materiałowej':
        case 'Katedra Mechaniki Stosowanej':
        case 'Katedra Obróbki Plastycznej Metali':
        case 'Katedra Podstaw Inżynierii Produkcji':
        case 'Katedra Podstaw Konstrukcji Maszyn i Mechatroniki':
        case 'Katedra Pojazdów Samochodowych':
        case 'Katedra Technologii i Przetwórstwa Tworzyw Polimerowych':
        case 'Katedra Termodynamiki Mechaniki Płynów i Napędów Lotniczych':
        case 'Katedra Zrównoważonego Transportu i Żródeł Napędu':
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
      body: SingleChildScrollView(
        child: Center(
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
                children: departmentsofMechanics.map((department) {
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
    );
  }
}