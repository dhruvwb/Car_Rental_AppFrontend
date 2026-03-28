class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String drivingLicenseNumber;
  final DateTime licenseExpiry;
  final String profileImage;
  final List<String> paymentMethods; // Card IDs
  final List<String> favoriteCarIds;
  final double rating;
  final int trips;
  final DateTime memberSince;
  final bool isVerified;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.drivingLicenseNumber,
    required this.licenseExpiry,
    required this.profileImage,
    required this.paymentMethods,
    required this.favoriteCarIds,
    required this.rating,
    required this.trips,
    required this.memberSince,
    required this.isVerified,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      drivingLicenseNumber: json['drivingLicenseNumber'] ?? '',
      licenseExpiry: DateTime.parse(json['licenseExpiry'] ?? DateTime.now().toString()),
      profileImage: json['profileImage'] ?? '',
      paymentMethods: List<String>.from(json['paymentMethods'] ?? []),
      favoriteCarIds: List<String>.from(json['favoriteCarIds'] ?? []),
      rating: (json['rating'] ?? 0.0).toDouble(),
      trips: json['trips'] ?? 0,
      memberSince: DateTime.parse(json['memberSince'] ?? DateTime.now().toString()),
      isVerified: json['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'drivingLicenseNumber': drivingLicenseNumber,
      'licenseExpiry': licenseExpiry.toIso8601String(),
      'profileImage': profileImage,
      'paymentMethods': paymentMethods,
      'favoriteCarIds': favoriteCarIds,
      'rating': rating,
      'trips': trips,
      'memberSince': memberSince.toIso8601String(),
      'isVerified': isVerified,
    };
  }
}
