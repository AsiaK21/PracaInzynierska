import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Funkcja do pobierania obecnie zalogowanego użytkownika
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Funkcja do logowania użytkownika
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential authResult = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return authResult.user;
    } catch (error) {
      print('Błąd logowania: $error');
      return null;
    }
  }

  // Funkcja do wylogowywania użytkownika
  Future<void> signOut() async {
    await _auth.signOut();
  }
}