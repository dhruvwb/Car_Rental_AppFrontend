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

  // Login with backend API
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.login(email, password);
      if (response['success'] == true) {
        _currentUser = _authService.getCurrentUser();
        return true;
      } else {
        _errorMessage = response['error'] ?? 'Login failed';
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

  // Register with backend API
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
      final response = await _authService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        drivingLicense: drivingLicense,
      );
      if (response['success'] == true) {
        _currentUser = _authService.getCurrentUser();
        return true;
      } else {
        _errorMessage = response['error'] ?? 'Registration failed';
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
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Logout error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check login status and get current user from backend
  Future<void> checkLoginStatus() async {
    if (_authService.isLoggedIn()) {
      try {
        final user = await _authService.getCurrentUserFromBackend();
        _currentUser = user;
      } catch (e) {
        // Use cached user if backend call fails
        _currentUser = _authService.getCurrentUser();
      }
    } else {
      _currentUser = null;
    }
    notifyListeners();
  }

  // Manually set user (for offline/mock mode)
  void setCurrentUser(User? user) {
    _currentUser = user;
    notifyListeners();
  }
}
