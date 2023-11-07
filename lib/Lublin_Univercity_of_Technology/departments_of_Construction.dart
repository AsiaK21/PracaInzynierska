import 'package:flutter/material.dart';

class ConstructionScreen extends StatefulWidget {
  @override
  _ConstructionScreenState createState() => _ConstructionScreenState();
}

class _ConstructionScreenState extends State<ConstructionScreen> {

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
