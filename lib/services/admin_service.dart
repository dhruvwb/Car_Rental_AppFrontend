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

  // Dummy admin credentials for testing
  static const String dummyAdminEmail = 'admin@carrental.com';
  static const String dummyAdminPassword = 'admin123';
  static const String adminToken = 'admin_jwt_token_12345';

  /// Admin login with dummy credentials
  Future<Map<String, dynamic>> adminLogin(String email, String password) async {
    try {
      if (email == dummyAdminEmail && password == dummyAdminPassword) {
        // Set the admin token
        await _httpClient.setAuthToken(adminToken);
        return {
          'success': true,
          'message': 'Admin login successful',
          'admin': {
            'id': 'admin_001',
            'name': 'Admin User',
            'email': email,
            'role': 'admin',
          },
          'token': adminToken,
        };
      } else {
        throw Exception('Invalid admin credentials');
      }
    } catch (e) {
      rethrow;
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

      // Extract car data from response
      final responseMap = response as Map<String, dynamic>;
      final carData = responseMap['car'] ?? responseMap;
      return _mapToCar(carData as Map<String, dynamic>);
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

      // Extract car data from response
      final responseMap = response as Map<String, dynamic>;
      final carData = responseMap['car'] ?? responseMap;
      return _mapToCar(carData as Map<String, dynamic>);
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
      final response = await _httpClient.get(
        ApiConstants.getBookingsEndpoint,
        includeAuth: true,
      );

      List<dynamic> bookingList = [];
      if (response is List) {
        bookingList = response as List<dynamic>;
      } else if (response is Map<String, dynamic>) {
        if (response.containsKey('data') && response['data'] is List) {
          bookingList = response['data'] as List<dynamic>;
        }
      }

      return bookingList.isEmpty
          ? []
          : bookingList
              .where((b) => (b as Map<String, dynamic>)['status'] == 'Pending')
              .map((booking) => _mapToBooking(booking as Map<String, dynamic>))
              .toList();
    } catch (e) {
      throw Exception('Failed to fetch bookings: $e');
    }
  }

  /// Approve a booking
  Future<Booking> approveBooking(String bookingId) async {
    try {
      final response = await _httpClient.put(
        '${ApiConstants.getBookingByIdEndpoint}/$bookingId',
        {'status': 'Confirmed'},
        includeAuth: true,
      );

      return _mapToBooking(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to approve booking: $e');
    }
  }

  /// Reject a booking
  Future<void> rejectBooking(String bookingId) async {
    try {
      await _httpClient.put(
        '${ApiConstants.getBookingByIdEndpoint}/$bookingId',
        {'status': 'Rejected'},
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
