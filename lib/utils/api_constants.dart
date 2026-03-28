class ApiConstants {
  // Backend base URL - Change this to your actual backend URL
  // For local development, use: http://10.0.2.2:5000 (Android emulator)
  // For physical device: http://YOUR_MACHINE_IP:5000
  // For production: https://your-production-domain.com
  static const String baseUrl = 'http://10.0.2.2:5000';
  static const String apiVersion = '/api/v1';

  // Auth Endpoints
  static const String loginEndpoint = '$apiVersion/auth/login';
  static const String registerEndpoint = '$apiVersion/auth/register';
  static const String getCurrentUserEndpoint = '$apiVersion/auth/me';

  // Cars Endpoints
  static const String getCarsEndpoint = '$apiVersion/cars';
  static const String getCarByIdEndpoint = '$apiVersion/cars';

  // Bookings Endpoints
  static const String createBookingEndpoint = '$apiVersion/bookings';
  static const String getBookingsEndpoint = '$apiVersion/bookings';
  static const String getBookingByIdEndpoint = '$apiVersion/bookings';
  static const String cancelBookingEndpoint = '$apiVersion/bookings';

  // Users Endpoints
  static const String getUserProfileEndpoint = '$apiVersion/users/profile';
  static const String updateUserProfileEndpoint = '$apiVersion/users/profile';

  // Health check
  static const String healthCheckEndpoint = '/api/health';

  // Timeout duration
  static const Duration timeoutDuration = Duration(seconds: 30);

  // Full URLs
  static String getFullUrl(String endpoint) => baseUrl + endpoint;

  // For development - change to your actual backend URL
  static String getBackendUrl() {
    return baseUrl;
  }
}
