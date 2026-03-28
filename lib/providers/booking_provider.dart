import 'package:flutter/material.dart';
import '../models/index.dart';
import '../services/index.dart';

class BookingProvider extends ChangeNotifier {
  final BookingService _bookingService = BookingService();

  Booking? _currentBooking;
  List<Booking> _userBookings = [];
  bool _isLoading = false;

  // Getters
  Booking? get currentBooking => _currentBooking;
  List<Booking> get userBookings => _userBookings;
  bool get isLoading => _isLoading;

  // Create booking
  Future<bool> createBooking({
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
    _isLoading = true;
    notifyListeners();

    try {
      _currentBooking = await _bookingService.createBooking(
        userId: userId,
        carId: carId,
        pickupDate: pickupDate,
        dropoffDate: dropoffDate,
        pickupLocation: pickupLocation,
        dropoffLocation: dropoffLocation,
        dailyRate: dailyRate,
        insuranceType: insuranceType,
        insuranceCost: insuranceCost,
        addOns: addOns,
        carRegistration: carRegistration,
        specialRequests: specialRequests,
      );
      return _currentBooking != null;
    } catch (e) {
      print('Error creating booking: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get user bookings
  Future<void> getUserBookings(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _userBookings = await _bookingService.getUserBookings(userId);
    } catch (e) {
      print('Error fetching user bookings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cancel booking
  Future<bool> cancelBooking(String bookingId) async {
    _isLoading = true;
    notifyListeners();

    try {
      return await _bookingService.cancelBooking(bookingId);
    } catch (e) {
      print('Error cancelling booking: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear current booking
  void clearCurrentBooking() {
    _currentBooking = null;
    notifyListeners();
  }
}
