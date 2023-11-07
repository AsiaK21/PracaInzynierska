import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projekt_inzynierski/Lublin_Univercity_of_Technology/departments_of_Informatics.dart';
import 'package:projekt_inzynierski/Lublin_Univercity_of_Technology/departments_of_Mechanics.dart';

import '../services/firebase_firestore_groups_service.dart';

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

  Future<void> addUserToFacultyGroup(String faculty, String userEmail) async {
    final groupId = 'faculty_$faculty'; // Assuming you have a naming convention for group IDs
    final groupRef = FirebaseFirestore.instance.collection('groups').doc(
        groupId);

    // Check if the group exists
    final groupDoc = await groupRef.get();
    if (groupDoc.exists) {
      // Add the user to the existing faculty group
      await groupRef.update({
        'participants': FieldValue.arrayUnion([userEmail]),
      });
    } else {
      // If the group doesn't exist, you can create it here if needed
      // You can create the group with the faculty name as the group name
      await FirebaseFirestoreGroupsService().createGroup(
          groupId, faculty, [userEmail]);
    }
  }

  void selectFaculty(String faculty) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userEmail = user.email; // Get the user's email

      final userData = {
        'selectedFaculty': faculty,
      };
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(userData);

      final groupId = 'faculty_$faculty'; // Assuming you have a naming convention for group IDs
      final groupRef = FirebaseFirestore.instance.collection('groups').doc(groupId);

      // Check if the group exists
      final groupDoc = await groupRef.get();
      if (groupDoc.exists) {
        // Add the user to the existing faculty group
        await groupRef.update({
          'participants': FieldValue.arrayUnion([userEmail]),
        });
      } else {
        // If the group doesn't exist, you can create it here if needed
        // You can create the group with the faculty name as the group name
        await FirebaseFirestoreGroupsService().createGroup(groupId, faculty, [userEmail!]);
      }

      // Determine which screen to navigate to based on the selected faculty
      switch (faculty) {
        case 'Wydział Mechaniczny':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MechanicsScreen(), // Replace with the actual MechanicalScreen
            ),
          );
          break;
        case 'Wydział Elektrotechniki i Informatyki':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => InformaticsScreen(), // Replace with the actual ElectricalScreen
            ),
          );
          break;
      // Add cases for other faculties here

        default:
          print('Selected faculty is not recognized.');
          break;
      }
    } else {
      // Handle the case where the user is not authenticated
      print('User is not authenticated.');
      // You may want to display an error message or take appropriate action.
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
                          primary: selectedFaculty == faculty ? Colors
                              .purpleAccent : null,
                          padding: const EdgeInsets.all(16.0),
                        ),
                        child: DefaultTextStyle(
                          style: TextStyle(
                            color: selectedFaculty == faculty
                                ? Colors.white
                                : Colors.black,
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

