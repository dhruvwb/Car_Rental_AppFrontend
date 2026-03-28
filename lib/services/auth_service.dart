import '../models/index.dart';

class AuthService {
  static User? _currentUser;

  // Login
  Future<bool> login(String email, String password) async {
    await Future.delayed(Duration(milliseconds: 1500));
    // Mock authentication
    if (email.isNotEmpty && password.isNotEmpty) {
      _currentUser = User(
        id: '1',
        name: 'John Doe',
        email: email,
        phone: '+1-800-123-4567',
        drivingLicenseNumber: 'DL123456789',
        licenseExpiry: DateTime.now().add(Duration(days: 365)),
        profileImage: 'assets/profile.jpg',
        paymentMethods: ['card_1', 'card_2'],
        favoriteCarIds: ['1', '4'],
        rating: 4.8,
        trips: 15,
        memberSince: DateTime.now().subtract(Duration(days: 365)),
        isVerified: true,
      );
      return true;
    }
    return false;
  }

  // Register
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String drivingLicense,
  }) async {
    await Future.delayed(Duration(milliseconds: 1500));
    // Mock registration
    if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      _currentUser = User(
        id: '${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        phone: phone,
        drivingLicenseNumber: drivingLicense,
        licenseExpiry: DateTime.now().add(Duration(days: 365 * 5)),
        profileImage: '',
        paymentMethods: [],
        favoriteCarIds: [],
        rating: 0,
        trips: 0,
        memberSince: DateTime.now(),
        isVerified: false,
      );
      return true;
    }
    return false;
  }

  // Logout
  Future<void> logout() async {
    await Future.delayed(Duration(milliseconds: 500));
    _currentUser = null;
  }

  // Get current user
  User? getCurrentUser() => _currentUser;

  // Check if user is logged in
  bool isLoggedIn() => _currentUser != null;
}
