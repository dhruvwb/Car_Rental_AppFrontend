class Enquiry {
  final String id;
  final String userId;
  final String pickupLocation;
  final String dropLocation;
  final DateTime pickupDateTime;
  final String contactName;
  final String contactPhone;
  final String contactEmail;
  final String? additionalNotes;
  final String status; // Pending, Responded, Confirmed, Completed, Cancelled
  final DateTime createdAt;
  final String? adminResponse;
  final DateTime? respondedAt;
  final double? quotedPrice;

  Enquiry({
    required this.id,
    required this.userId,
    required this.pickupLocation,
    required this.dropLocation,
    required this.pickupDateTime,
    required this.contactName,
    required this.contactPhone,
    required this.contactEmail,
    this.additionalNotes,
    required this.status,
    required this.createdAt,
    this.adminResponse,
    this.respondedAt,
    this.quotedPrice,
  });

  factory Enquiry.fromJson(Map<String, dynamic> json) {
    return Enquiry(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      pickupLocation: json['pickupLocation'] ?? '',
      dropLocation: json['dropLocation'] ?? '',
      pickupDateTime: DateTime.parse(json['pickupDateTime'] ?? DateTime.now().toString()),
      contactName: json['contactName'] ?? '',
      contactPhone: json['contactPhone'] ?? '',
      contactEmail: json['contactEmail'] ?? '',
      additionalNotes: json['additionalNotes'],
      status: json['status'] ?? 'Pending',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      adminResponse: json['adminResponse'],
      respondedAt: json['respondedAt'] != null ? DateTime.parse(json['respondedAt']) : null,
      quotedPrice: json['quotedPrice'] != null ? (json['quotedPrice'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'pickupLocation': pickupLocation,
      'dropLocation': dropLocation,
      'pickupDateTime': pickupDateTime.toIso8601String(),
      'contactName': contactName,
      'contactPhone': contactPhone,
      'contactEmail': contactEmail,
      'additionalNotes': additionalNotes,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'adminResponse': adminResponse,
      'respondedAt': respondedAt?.toIso8601String(),
      'quotedPrice': quotedPrice,
    };
  }
}
