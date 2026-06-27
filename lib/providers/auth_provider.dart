import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _firebaseUser;
  AppUser? _appUser;
  bool _loading = true;

  AuthProvider() {
    _authService.authStateChanges.listen(_onAuthChanged);
  }

  User? get firebaseUser => _firebaseUser;
  AppUser? get appUser => _appUser;
  bool get loading => _loading;
  bool get isLoggedIn => _firebaseUser != null;
  bool get isAdmin => _appUser?.isAdmin ?? false;

  Future<void> _onAuthChanged(User? user) async {
    _firebaseUser = user;
    if (user != null) {
      _appUser = await _authService.getUserProfile(user.uid);
    } else {
      _appUser = null;
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    await _authService.signIn(email, password);
  }

  Future<void> signUp(
      {required String email,
      required String password,
      required String username}) async {
    await _authService.signUp(
        email: email, password: password, username: username);
  }

  Future<void> sendPasswordReset(String email) {
    return _authService.sendPasswordReset(email);
  }

  Future<void> signOut() {
    return _authService.signOut();
  }
}
