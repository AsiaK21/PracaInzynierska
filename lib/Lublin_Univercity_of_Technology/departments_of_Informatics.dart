import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projekt_inzynierski/chats/chats.dart';
import 'package:projekt_inzynierski/univercity_chat/univercity_chat_screen.dart';
import '../services/firebase_firestore_univercity_service.dart';

class InformaticsSelectionScreen extends StatefulWidget {
  @override
  _InformaticsSelectionScreen createState() => _InformaticsSelectionScreen();
}

class _InformaticsSelectionScreen extends State<InformaticsSelectionScreen> {
  List<String> departmentsofInformatics = [
    'Katedra Automatyki i Metrologii',
    'Katedra Elektrotechniki i Technologii Nadprzewodowych',
    'Katedra Urządzeń Elektrycznych i Techniki Wysokich Napięć',
    'Katedra Elektroenergetyki',
    'Katedra Elektrotechniki i Technologii Inteligentnych',
    'Katedra Informatyki',
    'Katedra Elektrotechniki i Technik Informacyjnych',
    'Katedra Napędów i Maszyn Elektrycznych',
    'Katedra Matematyki'
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
        case 'Katedra Automatyki i Metrologii':
        case 'Katedra Elektrotechniki i Technologii Nadprzewodowych':
        case 'Katedra Urządzeń Elektrycznych i Techniki Wysokich Napięć':
        case 'Katedra Elektroenergetyki':
        case 'Katedra Elektrotechniki i Technologii Inteligentnych':
        case 'Katedra Informatyki':
        case 'Katedra Elektrotechniki i Technik Informacyjnych':
        case 'Katedra Napędów i Maszyn Elektrycznych':
        case 'Katedra Matematyki':
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
                  children: departmentsofInformatics.map((department) {
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
