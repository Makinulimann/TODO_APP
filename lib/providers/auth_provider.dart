import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CustomAuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  User? get user => _user;
  bool get isAuthenticated => _user != null;

  // Check apakah ada user yang sedang login
  Future<void> checkCurrentUser() async {
    _user = _auth.currentUser;
    notifyListeners();
  }

  // Login user
  Future<void> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      _user = userCredential.user;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Login gagal';
      if (e.code == 'user-not-found') {
        errorMessage = 'Pengguna tidak ditemukan';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Password salah';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Email tidak valid';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Terjadi kesalahan saat login: $e');
    }
  }

  // Registrasi user baru
  Future<void> register(String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      _user = userCredential.user;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Registrasi gagal';
      if (e.code == 'email-already-in-use') {
        errorMessage = 'Email sudah digunakan';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Password terlalu lemah';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Email tidak valid';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Terjadi kesalahan saat registrasi: $e');
    }
  }

  // Logout user
  Future<void> logout() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }
}
