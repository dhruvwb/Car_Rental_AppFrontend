import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_constants.dart';

class HttpClientService {
  static final HttpClientService _instance = HttpClientService._internal();
  final _secureStorage = const FlutterSecureStorage();
  String? _authToken;

  factory HttpClientService() {
    return _instance;
  }

  HttpClientService._internal();

  // Initialize - call this when app starts
  Future<void> initialize() async {
    _authToken = await _secureStorage.read(key: 'auth_token');
  }

  // Set auth token
  Future<void> setAuthToken(String token) async {
    _authToken = token;
    await _secureStorage.write(key: 'auth_token', value: token);
  }

  // Clear auth token on logout
  Future<void> clearAuthToken() async {
    _authToken = null;
    await _secureStorage.delete(key: 'auth_token');
  }

  // Get auth token
  String? getAuthToken() => _authToken;

  // Build headers
  Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  // GET request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    bool includeAuth = true,
    Map<String, String>? queryParameters,
  }) async {
    try {
      final url = Uri.parse(ApiConstants.baseUrl + endpoint)
          .replace(queryParameters: queryParameters);

      final response = await http
          .get(
            url,
            headers: _getHeaders(includeAuth: includeAuth),
          )
          .timeout(ApiConstants.timeoutDuration);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool includeAuth = true,
  }) async {
    try {
      final url = Uri.parse(ApiConstants.baseUrl + endpoint);

      final response = await http
          .post(
            url,
            headers: _getHeaders(includeAuth: includeAuth),
            body: jsonEncode(body),
          )
          .timeout(ApiConstants.timeoutDuration);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool includeAuth = true,
  }) async {
    try {
      final url = Uri.parse(ApiConstants.baseUrl + endpoint);

      final response = await http
          .put(
            url,
            headers: _getHeaders(includeAuth: includeAuth),
            body: jsonEncode(body),
          )
          .timeout(ApiConstants.timeoutDuration);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool includeAuth = true,
  }) async {
    try {
      final url = Uri.parse(ApiConstants.baseUrl + endpoint);

      final response = await http
          .delete(
            url,
            headers: _getHeaders(includeAuth: includeAuth),
          )
          .timeout(ApiConstants.timeoutDuration);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Handle response
  dynamic _handleResponse(http.Response response) {
    try {
      final body = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body;
      } else if (response.statusCode == 401) {
        // Unauthorized - token may be expired
        clearAuthToken();
        throw ApiException('Unauthorized. Please log in again.', 401);
      } else if (response.statusCode == 400) {
        throw ApiException(
          body is Map<String, dynamic> ? body['error'] ?? 'Bad request' : 'Bad request',
          response.statusCode,
        );
      } else if (response.statusCode == 404) {
        throw ApiException(
          body is Map<String, dynamic> ? body['error'] ?? 'Not found' : 'Not found',
          response.statusCode,
        );
      } else {
        throw ApiException(
          body is Map<String, dynamic> ? body['error'] ?? 'Server error' : 'Server error',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to parse response', 500);
    }
  }

  // Handle errors
  ApiException _handleError(Object error) {
    if (error is ApiException) return error;

    if (error.toString().contains('SocketException')) {
      return ApiException('Network error. Please check your connection.', 0);
    }

    if (error.toString().contains('TimeoutException')) {
      return ApiException('Request timeout. Please try again.', 0);
    }

    return ApiException('An unexpected error occurred: $error', 0);
  }
}

// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}
