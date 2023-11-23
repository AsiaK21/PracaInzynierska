import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projekt_inzynierski/chats/chats.dart';
import 'package:projekt_inzynierski/univercity_chat/univercity_chat_screen.dart';
import '../services/firebase_firestore_univercity_service.dart';

class ConstructionSelectionScreen extends StatefulWidget {
  @override
  _ConstructionSelectionScreen createState() => _ConstructionSelectionScreen();
}

class _ConstructionSelectionScreen extends State<ConstructionSelectionScreen> {
  List<String> departmentsofConstruction = [
    'Katedra Inżynierii Procesów Budowlanych',
    'Katedra Budownictwa Ogólnego',
    'Katedra Dróg i Mostów',
    'Katedra Mechaniki Ciała Stałego',
    'Katedra Konstrukcji Budowlanych',
    'Katedra Inżynierii Materiałów Budowlanych i Geoinżynierii',
    'Katedra Mechaniki Budowli',
    'Katedra Architektury, Urbanistyki i Planowania Przestrzennego',
    'Katedra Konserwacji Zabytków',
    'Katedra Architektury Współczesnej'
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
        case 'Katedra Inżynierii Procesów Budowlanych':
        case 'Katedra Budownictwa Ogólnego':
        case 'Katedra Dróg i Mostów':
        case 'Katedra Mechaniki Ciała Stałego':
        case 'Katedra Konstrukcji Budowlanych':
        case 'Katedra Inżynierii Materiałów Budowlanych i Geoinżynierii':
        case 'Katedra Mechaniki Budowli':
        case 'Katedra Architektury, Urbanistyki i Planowania Przestrzennego':
        case 'Katedra Konserwacji Zabytków':
        case 'Katedra Architektury Współczesnej':
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
                  children: departmentsofConstruction.map((department) {
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
