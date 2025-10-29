import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _initialize();
  }

  void _initialize() {
    _user = _firebaseService.currentUser;
    _firebaseService.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<bool> signUp(String email, String password, String name) async {
    _setLoading(true);
    _error = null;

    final error = await _firebaseService.signUp(email, password, name);
    
    if (error != null) {
      _error = error;
      _setLoading(false);
      return false;
    }

    _setLoading(false);
    return true;
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _error = null;

    final error = await _firebaseService.signIn(email, password);
    
    if (error != null) {
      _error = error;
      _setLoading(false);
      return false;
    }

    _setLoading(false);
    return true;
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _error = null;

    final error = await _firebaseService.signInWithGoogle();
    
    if (error != null) {
      _error = error;
      _setLoading(false);
      return false;
    }

    _setLoading(false);
    return true;
  }

  Future<void> signOut() async {
    await _firebaseService.signOut();
    _user = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
