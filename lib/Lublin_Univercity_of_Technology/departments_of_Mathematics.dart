import 'package:flutter/material.dart';

class MathematicsScreen extends StatefulWidget {
  @override
  _MathematicsScreenState createState() => _MathematicsScreenState();
}

class _MathematicsScreenState extends State<MathematicsScreen> {

  List<String> departmentsofMathematics = [
    'Katedra Inteligencji Obliczeniowej',
    'Katedra Informatyki Stosowanej',
    'Katedra Informatyki Technicznej',
    'Katedra Matematyki Stosowanej',
    'Katedra Metod i Technik Nauczania'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Witaj, z jakiej katedry jesteś?',
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
                      child: Text(department),
                      style: ElevatedButton.styleFrom(
                        primary: selectedDepartment == department ? Colors.purpleAccent : null,
                        padding: const EdgeInsets.all(16.0),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 16.0), // Dodanie przerwy między przyciskami
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
  String selectedDepartment = '';
  void selectDepartment(String department) {
    // Tutaj możesz dodać kod, który dodaje użytkownika do grupy czatu wydziałowego
    // Na przykład, jeśli używasz Firebase, możesz zaktualizować dokument użytkownika, aby zawierał informację o wybranym wydziale.

    // Przykład użycia Firebase:
    // final user = FirebaseAuth.instance.currentUser;
    // final userData = {
    //   'selectedFaculty': faculty,
    // };
    // await FirebaseFirestore.instance.collection('users').doc(user.uid).update(userData);

    // Przekierowanie do ekranu wyboru kierunku
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => CourseSelectionScreen(),
    //   ),
    // );
  }
}
