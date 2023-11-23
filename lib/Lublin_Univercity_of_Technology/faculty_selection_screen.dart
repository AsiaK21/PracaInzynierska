import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projekt_inzynierski/Lublin_Univercity_of_Technology/departments_of_Enviroment.dart';
import 'package:projekt_inzynierski/Lublin_Univercity_of_Technology/departments_of_Informatics.dart';
import 'package:projekt_inzynierski/Lublin_Univercity_of_Technology/departments_of_Managements.dart';
import 'package:projekt_inzynierski/Lublin_Univercity_of_Technology/departments_of_Mathematics.dart';
import 'package:projekt_inzynierski/Lublin_Univercity_of_Technology/departments_of_Mechanics.dart';

import '../services/firebase_firestore_univercity_service.dart';
import 'departments_of_Construction.dart';

class FacultySelectionScreen extends StatefulWidget {
  @override
  _FacultySelectionScreenState createState() => _FacultySelectionScreenState();
}

class _FacultySelectionScreenState extends State<FacultySelectionScreen> {
  List<String> facultyList = [
    'Wydział Mechaniczny',
    'Wydział Elektrotechniki i Informatyki',
    'Wydział Budownictwa i Architektury',
    'Wydział Inżynierii Środowiska',
    'Wydział Zarządzania',
    'Wydział Matematyki i Informatyki Technicznej'
  ];

  String selectedFaculty = '';

  void selectFaculty(String faculty) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userEmail = user.email;

      final userData = {
        'selectedFaculty': faculty,
      };

      final groupId = 'faculty_$faculty';
      await FirebaseFirestoreUnivercityService().addUserToGroup(groupId, userEmail!);

      switch (faculty) {
        case 'Wydział Mechaniczny':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MechanicsSelectionScreen(),
            ),
          );
          break;
        case 'Wydział Elektrotechniki i Informatyki':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => InformaticsSelectionScreen(),
            ),
          );
          break;
        case 'Wydział Budownictwa i Architektury':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ConstructionSelectionScreen(),
            ),
          );
          break;
        case 'Wydział Inżynierii Środowiska':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => EnvironmentSelectionScreen(),
            ),
          );
          break;
        case 'Wydział Zarządzania':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ManagementsSelectionScreen(),
            ),
          );
          break;
        case 'Wydział Matematyki i Informatyki Technicznej':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MathematicsSelectionScreen(),
            ),
          );
          break;
        default:
          print('Wybrany wydział nie jest rozpoznawany.');
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Witaj na którym jesteś wydziale ?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            Column(
              children: facultyList.map((faculty) {
                return Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedFaculty = faculty;
                        });
                        selectFaculty(faculty);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: selectedFaculty == faculty ? Colors.purpleAccent : null,
                        padding: const EdgeInsets.all(16.0),
                      ),
                      child: DefaultTextStyle(
                        style: TextStyle(
                          color: selectedFaculty == faculty ? Colors.white : Colors.black,
                          fontSize: 16,
                        ),
                        child: Text(faculty),
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
    );
  }
}
