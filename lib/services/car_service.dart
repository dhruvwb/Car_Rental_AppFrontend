import '../models/index.dart';

class CarService {
  // Mock data - in real app, this would call an API
  static final List<Car> _mockCars = [
    Car(
      id: '1',
      name: 'Honda Civic',
      model: 'Civic 2023',
      year: 2023,
      type: 'Sedan',
      dailyRate: 32.0,
      transmission: 'Automatic',
      fuel: 'Petrol',
      seats: 5,
      luggage: 420,
      features: ['AC', 'Power Steering', 'ABS', 'Airbags', 'USB Charging'],
      images: ['assets/cars/civic_1.jpg', 'assets/cars/civic_2.jpg'],
      rating: 4.9,
      reviews: 256,
      registrationNumber: 'NY-45-XYZ',
      isAvailable: true,
    ),
    Car(
      id: '2',
      name: 'Toyota Fortuner',
      model: 'Fortuner 2024',
      year: 2024,
      type: 'SUV',
      dailyRate: 56.0,
      transmission: 'Automatic',
      fuel: 'Diesel',
      seats: 7,
      luggage: 600,
      features: ['AC', 'Power Steering', '4WD', 'Touchscreen', 'Cruise Control'],
      images: ['assets/cars/fortuner_1.jpg', 'assets/cars/fortuner_2.jpg'],
      rating: 4.7,
      reviews: 189,
      registrationNumber: 'NY-28-ABC',
      isAvailable: true,
    ),
    Car(
      id: '3',
      name: 'Maruti Swift',
      model: 'Swift 2023',
      year: 2023,
      type: 'Economy',
      dailyRate: 25.0,
      transmission: 'Manual',
      fuel: 'Petrol',
      seats: 5,
      luggage: 268,
      features: ['AC', 'Power Steering', 'ABS', 'Parking Sensors'],
      images: ['assets/cars/swift_1.jpg', 'assets/cars/swift_2.jpg'],
      rating: 4.6,
      reviews: 342,
      registrationNumber: 'NY-32-DEF',
      isAvailable: true,
    ),
    Car(
      id: '4',
      name: 'BMW 3 Series',
      model: '330i 2024',
      year: 2024,
      type: 'Premium',
      dailyRate: 95.0,
      transmission: 'Automatic',
      fuel: 'Petrol',
      seats: 5,
      luggage: 480,
      features: ['AC', 'Leather Seats', 'Panoramic Sunroof', 'WiFi', 'Premium Sound'],
      images: ['assets/cars/bmw_1.jpg', 'assets/cars/bmw_2.jpg'],
      rating: 4.8,
      reviews: 87,
      registrationNumber: 'NY-15-GHI',
      isAvailable: true,
    ),
    Car(
      id: '5',
      name: 'Mahindra XUV500',
      model: 'XUV500 2023',
      year: 2023,
      type: 'SUV',
      dailyRate: 45.0,
      transmission: 'Automatic',
      fuel: 'Diesel',
      seats: 7,
      luggage: 550,
      features: ['AC', 'Power Steering', 'All-Wheel Drive', '360 Camera'],
      images: ['assets/cars/xuv_1.jpg', 'assets/cars/xuv_2.jpg'],
      rating: 4.5,
      reviews: 165,
      registrationNumber: 'NY-50-JKL',
      isAvailable: true,
    ),
  ];

  // Fetch all cars
  Future<List<Car>> getAllCars() async {
    await Future.delayed(Duration(milliseconds: 500)); // Simulate API call
    return _mockCars;
  }

  // Search cars with filters
  Future<List<Car>> searchCars({
    required String location,
    required DateTime pickupDate,
    required DateTime dropoffDate,
    String? carType,
    double? minPrice,
    double? maxPrice,
    double? minRating,
  }) async {
    await Future.delayed(Duration(milliseconds: 800)); // Simulate API call

    List<Car> filtered = _mockCars.where((car) {
      if (carType != null && car.type != carType) return false;
      if (minPrice != null && car.dailyRate < minPrice) return false;
      if (maxPrice != null && car.dailyRate > maxPrice) return false;
      if (minRating != null && car.rating < minRating) return false;
      return car.isAvailable;
    }).toList();

    return filtered;
  }

  // Get car by ID
  Future<Car?> getCarById(String id) async {
    await Future.delayed(Duration(milliseconds: 300));
    try {
      return _mockCars.firstWhere((car) => car.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get cars by type
  Future<List<Car>> getCarsByType(String type) async {
    await Future.delayed(Duration(milliseconds: 400));
    return _mockCars.where((car) => car.type == type).toList();
  }
}
