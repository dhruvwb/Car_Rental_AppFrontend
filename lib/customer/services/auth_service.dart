import '../../models/index.dart';
import '../../utils/http_client_service.dart';
import '../../utils/api_constants.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  static User? _currentUser;
  final _httpClient = HttpClientService();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  // Login with backend API
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _httpClient.post(
        ApiConstants.loginEndpoint,
        {
          'email': email,
          'password': password,
        },
        includeAuth: false,
      );

      // Store token
      if (response['token'] != null) {
        await _httpClient.setAuthToken(response['token']);
      }

      // Create user object from response
      final userData = response['user'] as Map<String, dynamic>;
      _currentUser = User(
        id: userData['id'].toString(),
        name: userData['name'] ?? '',
        email: userData['email'] ?? '',
        phone: userData['phone'] ?? '',
        drivingLicenseNumber: userData['driving_license_number'] ?? '',
        licenseExpiry: userData['license_expiry'] != null
            ? DateTime.parse(userData['license_expiry'])
            : DateTime.now().add(Duration(days: 365)),
        profileImage: userData['profile_image'] ?? '',
        paymentMethods: [],
        favoriteCarIds: [],
        rating: userData['rating'] ?? 0.0,
        trips: userData['trips'] ?? 0,
        memberSince: userData['created_at'] != null
            ? DateTime.parse(userData['created_at'])
            : DateTime.now(),
        isVerified: userData['is_verified'] ?? false,
      );

      return {
        'success': true,
        'token': response['token'],
        'user': _currentUser?.toJson(),
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Register with backend API
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String drivingLicense,
  }) async {
    try {
      // Note: Backend currently only supports name, email, password, phone
      // Driving license will be handled separately in profile update
      final response = await _httpClient.post(
        ApiConstants.registerEndpoint,
        {
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
        },
        includeAuth: false,
      );

      // Store token
      if (response['token'] != null) {
        await _httpClient.setAuthToken(response['token']);
      }

      // Create user object from response
      final userData = response['user'] as Map<String, dynamic>;
      _currentUser = User(
        id: userData['id'].toString(),
        name: userData['name'] ?? '',
        email: userData['email'] ?? '',
        phone: userData['phone'] ?? '',
        drivingLicenseNumber: drivingLicense,
        licenseExpiry: DateTime.now().add(Duration(days: 365 * 5)),
        profileImage: '',
        paymentMethods: [],
        favoriteCarIds: [],
        rating: 0.0,
        trips: 0,
        memberSince: DateTime.now(),
        isVerified: false,
      );

      return {
        'success': true,
        'token': response['token'],
        'user': _currentUser?.toJson(),
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Get current user from backend
  Future<User?> getCurrentUserFromBackend() async {
    try {
      final response = await _httpClient.get(
        ApiConstants.getCurrentUserEndpoint,
        includeAuth: true,
      );

      final userData = response as Map<String, dynamic>;
      _currentUser = User(
        id: userData['id'].toString(),
        name: userData['name'] ?? '',
        email: userData['email'] ?? '',
        phone: userData['phone'] ?? '',
        drivingLicenseNumber: userData['driving_license_number'] ?? '',
        licenseExpiry: userData['license_expiry'] != null
            ? DateTime.parse(userData['license_expiry'])
            : DateTime.now().add(Duration(days: 365)),
        profileImage: userData['profile_image'] ?? '',
        paymentMethods: [],
        favoriteCarIds: [],
        rating: userData['rating'] ?? 0.0,
        trips: userData['trips'] ?? 0,
        memberSince: userData['created_at'] != null
            ? DateTime.parse(userData['created_at'])
            : DateTime.now(),
        isVerified: userData['is_verified'] ?? false,
      );

      return _currentUser;
    } catch (e) {
      return null;
    }
  }

  // Logout
  Future<void> logout() async {
    _currentUser = null;
    await _httpClient.clearAuthToken();
  }

  // Get current user from cache
  User? getCurrentUser() => _currentUser;

  // Check if user is logged in
  bool isLoggedIn() => _currentUser != null && _httpClient.getAuthToken() != null;

  // Get auth token
  String? getAuthToken() => _httpClient.getAuthToken();
}
