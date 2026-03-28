import '../models/index.dart';

class BookingService {
  static final List<Booking> _bookings = [];

  // Create a new booking
  Future<Booking?> createBooking({
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
    await Future.delayed(Duration(milliseconds: 1000));

    final int numberOfDays = dropoffDate.difference(pickupDate).inDays + 1;
    final double subtotal = dailyRate * numberOfDays;
    final double tax = subtotal * 0.18; // 18% tax
    final double addOnsCost = addOns.fold(0, (sum, addon) => sum + (addon['cost'] ?? 0.0));
    final double totalCost = subtotal + insuranceCost + addOnsCost + tax;

    final booking = Booking(
      id: 'BR-${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      carId: carId,
      pickupDate: pickupDate,
      dropoffDate: dropoffDate,
      pickupLocation: pickupLocation,
      dropoffLocation: dropoffLocation,
      dailyRate: dailyRate,
      numberOfDays: numberOfDays,
      insuranceType: insuranceType,
      insuranceCost: insuranceCost,
      addOns: addOns,
      subtotal: subtotal,
      tax: tax,
      totalCost: totalCost,
      status: 'Confirmed',
      bookingDate: DateTime.now(),
      carRegistration: carRegistration,
      specialRequests: specialRequests,
    );

    _bookings.add(booking);
    return booking;
  }

  // Get booking by ID
  Future<Booking?> getBookingById(String id) async {
    await Future.delayed(Duration(milliseconds: 300));
    try {
      return _bookings.firstWhere((booking) => booking.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get all bookings for a user
  Future<List<Booking>> getUserBookings(String userId) async {
    await Future.delayed(Duration(milliseconds: 500));
    return _bookings.where((booking) => booking.userId == userId).toList();
  }

  // Cancel booking
  Future<bool> cancelBooking(String bookingId) async {
    await Future.delayed(Duration(milliseconds: 500));
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
