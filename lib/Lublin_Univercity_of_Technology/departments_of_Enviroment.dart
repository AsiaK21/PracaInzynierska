import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projekt_inzynierski/chats/chats.dart';
import 'package:projekt_inzynierski/univercity_chat/univercity_chat_screen.dart';
import '../services/firebase_firestore_univercity_service.dart';

class EnvironmentSelectionScreen extends StatefulWidget {
  @override
  _EnvironmentSelectionScreen createState() => _EnvironmentSelectionScreen();
}

class _EnvironmentSelectionScreen extends State<EnvironmentSelectionScreen> {
  List<String> departmentsofEnvironment = [
    'Katedra Inżynierii Ochrony Środowiska',
    'Katedra Inżynierii Odnawialnych Źródeł Energii',
    'Katedra Jakości Powietrza Wewnętrznego i Zewnętrznego',
    'Katedra Zaopatrzenia w Wodę i Usuwania Ścieków',
    'Katedra Konwersji Biomasy i Odpadów w Biopaliwa'
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
        case 'Katedra Inżynierii Ochrony Środowiska':
        case 'Katedra Inżynierii Odnawialnych Źródeł Energii':
        case 'Katedra Jakości Powietrza Wewnętrznego i Zewnętrznego':
        case 'Katedra Zaopatrzenia w Wodę i Usuwania Ścieków':
        case 'Katedra Konwersji Biomasy i Odpadów w Biopaliwa':
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
                  children: departmentsofEnvironment.map((department) {
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
