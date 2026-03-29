import 'package:myapp/models/car.dart';
import 'package:myapp/models/booking.dart';
import 'package:myapp/utils/http_client_service.dart';
import 'package:myapp/utils/api_constants.dart';

class AdminService {
  static final AdminService _instance = AdminService._internal();
  final _httpClient = HttpClientService();

  factory AdminService() {
    return _instance;
  }

  AdminService._internal();

  // Admin credentials for testing (matches backend mock auth)
  static const String dummyAdminEmail = 'admin@example.com';
  static const String dummyAdminPassword = 'admin123';

  /// Admin login - calls backend API
  Future<Map<String, dynamic>> adminLogin(String email, String password) async {
    try {
      // Call backend login endpoint
      final response = await _httpClient.post(
        ApiConstants.loginEndpoint,
        {
          'email': email,
          'password': password,
        },
        includeAuth: false, // No auth needed for login
      );

      // Extract token from response
      if (response is Map<String, dynamic> && response.containsKey('token')) {
        final token = response['token'];
        
        // Store the token for future authenticated requests
        await _httpClient.setAuthToken(token);

        return {
          'success': true,
          'message': 'Admin login successful',
          'admin': {
            'id': response['user']?['id'] ?? 'admin_001',
            'name': response['user']?['name'] ?? 'Admin User',
            'email': response['user']?['email'] ?? email,
            'role': 'admin',
          },
          'token': token,
        };
      } else {
        throw Exception('Invalid response format from server');
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  /// Admin logout
  Future<void> adminLogout() async {
    try {
      await _httpClient.clearAuthToken();
    } catch (e) {
      rethrow;
    }
  }

  /// Admin signup - register new admin account
  Future<Map<String, dynamic>> adminSignup({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String company,
  }) async {
    try {
      // Call backend register endpoint
      // Note: Backend only expects name, email, password, phone
      // Company field is stored locally for future use
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

      if (response is Map<String, dynamic> && response.containsKey('token')) {
        return {
          'success': true,
          'message': 'Admin registered successfully',
          'token': response['token'],
          'user': response['user'],
        };
      } else {
        throw Exception('Invalid response format from server');
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Signup failed: $e',
      };
    }
  }

  /// Get all cars for admin panel
  Future<List<Car>> getAllCarsForAdmin() async {
    try {
      final response = await _httpClient.get(
        ApiConstants.getCarsEndpoint,
        includeAuth: true,
      );

      List<dynamic> carList = [];
      if (response is List) {
        carList = response as List<dynamic>;
      } else if (response is Map<String, dynamic>) {
        if (response.containsKey('data') && response['data'] is List) {
          carList = response['data'] as List<dynamic>;
        }
      }

      return carList.isEmpty
          ? []
          : carList.map((car) => _mapToCar(car as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to fetch cars: $e');
    }
  }

  /// Add a new car
  Future<Car> addCar({
    required String name,
    required String model,
    required int year,
    required String type,
    required double dailyRate,
    required String transmission,
    required String fuel,
    required int seats,
    required int luggage,
    required List<String> features,
    required List<String> images,
    required String registrationNumber,
  }) async {
    try {
      final response = await _httpClient.post(
        ApiConstants.getCarsEndpoint,
        {
          'name': name,
          'model': model,
          'year': year,
          'type': type,
          'daily_rate': dailyRate,
          'transmission': transmission,
          'fuel': fuel,
          'seats': seats,
          'luggage': luggage,
          'features': features,
          'images': images,
          'registration_number': registrationNumber,
          'available': true,
        },
        includeAuth: true,
      );

      return _mapToCar(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to add car: $e');
    }
  }

  /// Update car details
  Future<Car> updateCar({
    required String carId,
    required String name,
    required String model,
    required int year,
    required String type,
    required double dailyRate,
    required String transmission,
    required String fuel,
    required int seats,
    required int luggage,
    required List<String> features,
    required List<String> images,
    required String registrationNumber,
    required bool available,
  }) async {
    try {
      final response = await _httpClient.put(
        '${ApiConstants.getCarByIdEndpoint}/$carId',
        {
          'name': name,
          'model': model,
          'year': year,
          'type': type,
          'daily_rate': dailyRate,
          'transmission': transmission,
          'fuel': fuel,
          'seats': seats,
          'luggage': luggage,
          'features': features,
          'images': images,
          'registration_number': registrationNumber,
          'available': available,
        },
        includeAuth: true,
      );

      return _mapToCar(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update car: $e');
    }
  }

  /// Delete a car
  Future<void> deleteCar(String carId) async {
    try {
      await _httpClient.delete(
        '${ApiConstants.getCarByIdEndpoint}/$carId',
        includeAuth: true,
      );
    } catch (e) {
      throw Exception('Failed to delete car: $e');
    }
  }

  /// Get all pending bookings/enquiries
  Future<List<Booking>> getPendingBookings() async {
    try {
      print('👨‍💼 [AdminService] Fetching pending bookings from: ${ApiConstants.getAdminBookingsEndpoint}');
      
      final response = await _httpClient.get(
        ApiConstants.getAdminBookingsEndpoint,
        includeAuth: true,
      );

      print('📋 [AdminService] Response received: $response');

      List<dynamic> bookingList = [];
      if (response is List) {
        bookingList = response as List<dynamic>;
      } else if (response is Map<String, dynamic>) {
        if (response.containsKey('data') && response['data'] is List) {
          bookingList = response['data'] as List<dynamic>;
        }
      }

      final List<Booking> pending = bookingList.isEmpty
          ? []
          : bookingList
              .where((b) => (b as Map<String, dynamic>)['status'] == 'Pending')
              .map((booking) => _mapToBooking(booking as Map<String, dynamic>))
              .toList();
      
      print('✅ [AdminService] Found ${pending.length} pending bookings');
      return pending;
    } catch (e) {
      print('❌ [AdminService] Failed to fetch pending bookings: $e');
      throw Exception('Failed to fetch bookings: $e');
    }
  }

  /// Get all bookings (not just pending)
  Future<List<Booking>> getAllBookings() async {
    try {
      print('👨‍💼 [AdminService] Fetching ALL bookings from: ${ApiConstants.getAdminBookingsEndpoint}');
      
      final response = await _httpClient.get(
        ApiConstants.getAdminBookingsEndpoint,
        includeAuth: true,
      );

      print('📋 [AdminService] Response received: $response');

      List<dynamic> bookingList = [];
      if (response is List) {
        bookingList = response as List<dynamic>;
      } else if (response is Map<String, dynamic>) {
        if (response.containsKey('data') && response['data'] is List) {
          bookingList = response['data'] as List<dynamic>;
        }
      }

      final List<Booking> allBookings = bookingList.isEmpty
          ? []
          : bookingList
              .map((booking) => _mapToBooking(booking as Map<String, dynamic>))
              .toList();
      
      print('✅ [AdminService] Found ${allBookings.length} total bookings');
      return allBookings;
    } catch (e) {
      print('❌ [AdminService] Failed to fetch all bookings: $e');
      throw Exception('Failed to fetch bookings: $e');
    }
  }

  /// Get all enquiries (admin only)
  Future<List<Map<String, dynamic>>> getAllEnquiries() async {
    try {
      final response = await _httpClient.get(
        ApiConstants.getAllEnquiriesAdminEndpoint,
        includeAuth: true,
      );

      List<dynamic> enquiriesList = [];
      if (response is List) {
        enquiriesList = response as List<dynamic>;
      } else if (response is Map<String, dynamic>) {
        if (response.containsKey('data') && response['data'] is List) {
          enquiriesList = response['data'] as List<dynamic>;
        }
      }

      return enquiriesList.isEmpty
          ? []
          : enquiriesList.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      print('Failed to fetch enquiries: $e');
      return [];
    }
  }

  /// Respond to an enquiry
  Future<Map<String, dynamic>> respondToEnquiry({
    required String enquiryId,
    required String adminResponse,
    required double quotedPrice,
  }) async {
    try {
      final response = await _httpClient.post(
        '${ApiConstants.respondToEnquiryEndpoint}/$enquiryId/respond',
        {
          'adminResponse': adminResponse,
          'quotedPrice': quotedPrice,
        },
        includeAuth: true,
      );

      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to respond to enquiry: $e');
    }
  }

  /// Approve a booking
  Future<Booking> approveBooking(String bookingId) async {
    try {
      final response = await _httpClient.put(
        '${ApiConstants.getBookingByIdEndpoint}/$bookingId/approve',
        {},
        includeAuth: true,
      );

      if (response is Map<String, dynamic> && response.containsKey('booking')) {
        return _mapToBooking(response['booking'] as Map<String, dynamic>);
      }
      return _mapToBooking(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to approve booking: $e');
    }
  }

  /// Reject a booking
  Future<void> rejectBooking(String bookingId, {String? reason}) async {
    try {
      await _httpClient.put(
        '${ApiConstants.getBookingByIdEndpoint}/$bookingId/reject',
        {'reason': reason ?? 'Rejected by admin'},
        includeAuth: true,
      );
    } catch (e) {
      throw Exception('Failed to reject booking: $e');
    }
  }

  /// Get dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final cars = await getAllCarsForAdmin();
      final bookings = await getPendingBookings();

      return {
        'totalCars': cars.length,
        'availableCars': cars.where((c) => c.isAvailable).length,
        'pendingBookings': bookings.length,
        'totalBookings': bookings.length,
      };
    } catch (e) {
      throw Exception('Failed to fetch dashboard stats: $e');
    }
  }

  // Mapping functions
  Car _mapToCar(Map<String, dynamic> data) {
    return Car(
      id: data['id'].toString(),
      name: data['name'] ?? '',
      model: data['model'] ?? '',
      year: data['year'] ?? DateTime.now().year,
      type: data['type'] ?? 'Sedan',
      dailyRate: (data['daily_rate'] ?? 0.0).toDouble(),
      transmission: data['transmission'] ?? 'Automatic',
      fuel: data['fuel'] ?? 'Petrol',
      seats: data['seats'] ?? 5,
      luggage: data['luggage'] ?? 300,
      features: List<String>.from(data['features'] ?? []),
      images: List<String>.from(data['images'] ?? []),
      rating: (data['rating'] ?? 4.0).toDouble(),
      reviews: data['reviews'] ?? 0,
      registrationNumber: data['registration_number'] ?? '',
      isAvailable: data['available'] ?? true,
    );
  }

  Booking _mapToBooking(Map<String, dynamic> data) {
    return Booking(
      id: data['id'].toString(),
      userId: data['user_id'].toString(),
      carId: data['car_id'].toString(),
      pickupDate: DateTime.parse(data['pickup_date']),
      dropoffDate: DateTime.parse(data['dropoff_date']),
      pickupLocation: data['pickup_location'] ?? '',
      dropoffLocation: data['dropoff_location'] ?? '',
      dailyRate: (data['daily_rate'] ?? 0.0).toDouble(),
      numberOfDays: data['number_of_days'] ?? 1,
      insuranceType: data['insurance_type'] ?? 'Basic',
      insuranceCost: (data['insurance_cost'] ?? 0.0).toDouble(),
      addOns: List<Map<String, dynamic>>.from(data['add_ons'] ?? []),
      subtotal: (data['subtotal'] ?? 0.0).toDouble(),
      tax: (data['tax'] ?? 0.0).toDouble(),
      totalCost: (data['total_cost'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'Pending',
      bookingDate: DateTime.parse(data['created_at'] ?? DateTime.now().toIso8601String()),
      carRegistration: data['car_registration'] ?? '',
      specialRequests: data['special_requests'],
    );
  }
}
