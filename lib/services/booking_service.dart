import '../models/index.dart';
import '../utils/http_client_service.dart';
import '../utils/api_constants.dart';

class BookingService {
  static final BookingService _instance = BookingService._internal();
  final _httpClient = HttpClientService();
  static final List<Booking> _bookings = [];

  factory BookingService() {
    return _instance;
  }

  BookingService._internal();

  // Convert API response to Booking object
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

  // Create a new booking
  Future<Booking> createBooking({
    required String userId,
    required String carId,
    required DateTime pickupDate,
    required DateTime dropoffDate,
    required String pickupLocation,
    required String dropoffLocation,
    required double dailyRate,
    required String insuranceType,
    required double insuranceCost,
    required List<Map<String, dynamic>> addOns,
    required String carRegistration,
    String? specialRequests,
  }) async {
    try {
      final response = await _httpClient.post(
        ApiConstants.createBookingEndpoint,
        {
          'user_id': userId,
          'car_id': carId,
          'pickup_date': pickupDate.toIso8601String(),
          'dropoff_date': dropoffDate.toIso8601String(),
          'pickup_location': pickupLocation,
          'dropoff_location': dropoffLocation,
          'daily_rate': dailyRate,
          'insurance_type': insuranceType,
          'insurance_cost': insuranceCost,
          'add_ons': addOns,
          'car_registration': carRegistration,
          'special_requests': specialRequests,
        },
        includeAuth: true,
      );

      // Handle response - could be the actual booking object or wrapped in 'data'
      Map<String, dynamic> bookingData;
      if (response is Map) {
        if (response.containsKey('data') && response['data'] is Map) {
          bookingData = response['data'] as Map<String, dynamic>;
        } else {
          bookingData = response;
        }
      } else {
        throw Exception('Unexpected response format');
      }
      
      final booking = _mapToBooking(bookingData);
      _bookings.add(booking); // Store locally as well
      return booking;
    } catch (e) {
      rethrow;
    }
  }

  // Get booking by ID
  Future<Booking?> getBookingById(String id) async {
    try {
      final response = await _httpClient.get(
        '${ApiConstants.getBookingByIdEndpoint}/$id',
        includeAuth: true,
      );

      return _mapToBooking(response as Map<String, dynamic>);
    } catch (e) {
      // Fallback to local bookings
      try {
        return _bookings.firstWhere((booking) => booking.id == id);
      } catch (e) {
        return null;
      }
    }
  }

  // Get all bookings for a user
  Future<List<Booking>> getUserBookings(String userId) async {
    try {
      final response = await _httpClient.get(
        ApiConstants.getBookingsEndpoint,
        queryParameters: {'user_id': userId},
        includeAuth: true,
      );

      // Handle both array and object responses
      List<dynamic> bookingList = [];
      if (response is List) {
        bookingList = response as List<dynamic>;
      } else if (response is Map<String, dynamic>) {
        if (response.containsKey('data') && response['data'] is List) {
          bookingList = response['data'] as List<dynamic>;
        }
      }
      
      return bookingList.isEmpty
          ? _bookings.where((booking) => booking.userId == userId).toList()
          : bookingList.map((booking) => _mapToBooking(booking as Map<String, dynamic>)).toList();
    } catch (e) {
      return _bookings.where((booking) => booking.userId == userId).toList();
    }
  }

  // Cancel booking
  Future<bool> cancelBooking(String bookingId) async {
    try {
      await _httpClient.delete(
        '${ApiConstants.cancelBookingEndpoint}/$bookingId',
        includeAuth: true,
      );
      return true;
    } catch (e) {
      // Fallback to local update
      try {
        final index = _bookings.indexWhere((b) => b.id == bookingId);
        if (index != -1) {
          final booking = _bookings[index];
          _bookings[index] = Booking(
            id: booking.id,
            userId: booking.userId,
            carId: booking.carId,
            pickupDate: booking.pickupDate,
            dropoffDate: booking.dropoffDate,
            pickupLocation: booking.pickupLocation,
            dropoffLocation: booking.dropoffLocation,
            dailyRate: booking.dailyRate,
            numberOfDays: booking.numberOfDays,
            insuranceType: booking.insuranceType,
            insuranceCost: booking.insuranceCost,
            addOns: booking.addOns,
            subtotal: booking.subtotal,
            tax: booking.tax,
            totalCost: booking.totalCost,
            status: 'Cancelled',
            bookingDate: booking.bookingDate,
            carRegistration: booking.carRegistration,
            specialRequests: booking.specialRequests,
          );
          return true;
        }
        return false;
      } catch (e) {
        return false;
      }
    }
  }
}
