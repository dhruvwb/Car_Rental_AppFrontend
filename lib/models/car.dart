class Car {
  final String id;
  final String name;
  final String model;
  final int year;
  final String type; // Economy, Sedan, SUV, Premium, Van
  final double dailyRate;
  final String transmission; // Auto, Manual
  final String fuel; // Petrol, Diesel, Electric, Hybrid
  final int seats;
  final int luggage;
  final List<String> features; // AC, Power Steering, WiFi, etc.
  final List<String> images;
  final double rating;
  final int reviews;
  final String registrationNumber;
  final bool isAvailable;

  Car({
    required this.id,
    required this.name,
    required this.model,
    required this.year,
    required this.type,
    required this.dailyRate,
    required this.transmission,
    required this.fuel,
    required this.seats,
    required this.luggage,
    required this.features,
    required this.images,
    required this.rating,
    required this.reviews,
    required this.registrationNumber,
    required this.isAvailable,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] ?? 2023,
      type: json['type'] ?? 'Sedan',
      dailyRate: (json['dailyRate'] ?? 0.0).toDouble(),
      transmission: json['transmission'] ?? 'Auto',
      fuel: json['fuel'] ?? 'Petrol',
      seats: json['seats'] ?? 5,
      luggage: json['luggage'] ?? 400,
      features: List<String>.from(json['features'] ?? []),
      images: List<String>.from(json['images'] ?? []),
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviews: json['reviews'] ?? 0,
      registrationNumber: json['registrationNumber'] ?? '',
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'model': model,
      'year': year,
      'type': type,
      'dailyRate': dailyRate,
      'transmission': transmission,
      'fuel': fuel,
      'seats': seats,
      'luggage': luggage,
      'features': features,
      'images': images,
      'rating': rating,
      'reviews': reviews,
      'registrationNumber': registrationNumber,
      'isAvailable': isAvailable,
    };
  }
}
