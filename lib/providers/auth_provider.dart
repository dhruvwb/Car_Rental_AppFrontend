import 'package:flutter/material.dart';
import '../models/index.dart';
import '../services/index.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _authService.isLoggedIn();

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authService.login(email, password);
      if (success) {
        _currentUser = _authService.getCurrentUser();
        return true;
      } else {
        _errorMessage = 'Invalid email or password';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Login error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String drivingLicense,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        drivingLicense: drivingLicense,
      );
      if (success) {
        _currentUser = _authService.getCurrentUser();
        return true;
      } else {
        _errorMessage = 'Registration failed';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Registration error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _currentUser = null;
    } catch (e) {
      _errorMessage = 'Logout error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check login status
  void checkLoginStatus() {
    _currentUser = _authService.getCurrentUser();
    notifyListeners();
  }
}
