import 'package:flutter/material.dart';

class MechanicsScreen extends StatefulWidget {
  @override
  _MechanicsScreenState createState() => _MechanicsScreenState();
}

class _MechanicsScreenState extends State<MechanicsScreen> {

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
