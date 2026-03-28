class Booking {
  final String id;
  final String userId;
  final String carId;
  final DateTime pickupDate;
  final DateTime dropoffDate;
  final String pickupLocation;
  final String dropoffLocation;
  final double dailyRate;
  final int numberOfDays;
  final String insuranceType; // None, Basic, Advanced, Premium
  final double insuranceCost;
  final List<Map<String, dynamic>> addOns; // [{name: "", cost: 0}]
  final double subtotal;
  final double tax;
  final double totalCost;
  final String status; // Confirmed, Completed, Cancelled, Ongoing
  final DateTime bookingDate;
  final String? carRegistration;
  final String? specialRequests;

  Booking({
    required this.id,
    required this.userId,
    required this.carId,
    required this.pickupDate,
    required this.dropoffDate,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.dailyRate,
    required this.numberOfDays,
    required this.insuranceType,
    required this.insuranceCost,
    required this.addOns,
    required this.subtotal,
    required this.tax,
    required this.totalCost,
    required this.status,
    required this.bookingDate,
    this.carRegistration,
    this.specialRequests,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      carId: json['carId'] ?? '',
      pickupDate: DateTime.parse(json['pickupDate'] ?? DateTime.now().toString()),
      dropoffDate: DateTime.parse(json['dropoffDate'] ?? DateTime.now().toString()),
      pickupLocation: json['pickupLocation'] ?? '',
      dropoffLocation: json['dropoffLocation'] ?? '',
      dailyRate: (json['dailyRate'] ?? 0.0).toDouble(),
      numberOfDays: json['numberOfDays'] ?? 1,
      insuranceType: json['insuranceType'] ?? 'None',
      insuranceCost: (json['insuranceCost'] ?? 0.0).toDouble(),
      addOns: List<Map<String, dynamic>>.from(json['addOns'] ?? []),
      subtotal: (json['subtotal'] ?? 0.0).toDouble(),
      tax: (json['tax'] ?? 0.0).toDouble(),
      totalCost: (json['totalCost'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'Confirmed',
      bookingDate: DateTime.parse(json['bookingDate'] ?? DateTime.now().toString()),
      carRegistration: json['carRegistration'],
      specialRequests: json['specialRequests'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'carId': carId,
      'pickupDate': pickupDate.toIso8601String(),
      'dropoffDate': dropoffDate.toIso8601String(),
      'pickupLocation': pickupLocation,
      'dropoffLocation': dropoffLocation,
      'dailyRate': dailyRate,
      'numberOfDays': numberOfDays,
      'insuranceType': insuranceType,
      'insuranceCost': insuranceCost,
      'addOns': addOns,
      'subtotal': subtotal,
      'tax': tax,
      'totalCost': totalCost,
      'status': status,
      'bookingDate': bookingDate.toIso8601String(),
      'carRegistration': carRegistration,
      'specialRequests': specialRequests,
    };
  }
}
