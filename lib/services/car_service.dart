import '../models/index.dart';
import '../utils/http_client_service.dart';
import '../utils/api_constants.dart';

class CarService {
  static final CarService _instance = CarService._internal();
  final _httpClient = HttpClientService();

  // Mock data fallback for offline mode
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

  factory CarService() {
    return _instance;
  }

  CarService._internal();

  // Convert API response to Car object
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

  // Fetch all cars from backend
  Future<List<Car>> getAllCars() async {
    try {
      final response = await _httpClient.get(
        ApiConstants.getCarsEndpoint,
        includeAuth: false,
      );

      // Handle both array and object responses
      List<dynamic> carList = [];
      if (response is List) {
        carList = response as List<dynamic>;
      } else if (response is Map<String, dynamic>) {
        if (response.containsKey('data') && response['data'] is List) {
          carList = response['data'] as List<dynamic>;
        }
      }
      
      return carList.isEmpty
          ? _mockCars
          : carList.map((car) => _mapToCar(car as Map<String, dynamic>)).toList();
    } catch (e) {
      // Fallback to mock data
      return _mockCars;
    }
  }

  // Search cars with filters from backend
  Future<List<Car>> searchCars({
    required String location,
    required DateTime pickupDate,
    required DateTime dropoffDate,
    String? carType,
    double? minPrice,
    double? maxPrice,
    double? minRating,
  }) async {
    try {
      final queryParams = {
        'location': location,
        'pickupDate': pickupDate.toIso8601String(),
        'dropoffDate': dropoffDate.toIso8601String(),
      };

      if (carType != null) queryParams['carType'] = carType;
      if (minPrice != null) queryParams['minPrice'] = minPrice.toString();
      if (maxPrice != null) queryParams['maxPrice'] = maxPrice.toString();
      if (minRating != null) queryParams['minRating'] = minRating.toString();

      final response = await _httpClient.get(
        ApiConstants.getCarsEndpoint,
        queryParameters: queryParams,
        includeAuth: false,
      );

      // Handle both array and object responses
      List<dynamic> carList = [];
      if (response is List) {
        carList = response as List<dynamic>;
      } else if (response is Map<String, dynamic>) {
        if (response.containsKey('data') && response['data'] is List) {
          carList = response['data'] as List<dynamic>;
        }
      }
      
      return carList.isEmpty
          ? _mockCars.where((car) {
              if (carType != null && car.type != carType) return false;
              if (minPrice != null && car.dailyRate < minPrice) return false;
              if (maxPrice != null && car.dailyRate > maxPrice) return false;
              if (minRating != null && car.rating < minRating) return false;
              return car.isAvailable;
            }).toList()
          : carList.map((car) => _mapToCar(car as Map<String, dynamic>)).toList();
    } catch (e) {
      // Fallback to filtered mock data on error
      return _mockCars.where((car) {
        if (carType != null && car.type != carType) return false;
        if (minPrice != null && car.dailyRate < minPrice) return false;
        if (maxPrice != null && car.dailyRate > maxPrice) return false;
        if (minRating != null && car.rating < minRating) return false;
        return car.isAvailable;
      }).toList();
    }
  }

  // Get car by ID from backend
  Future<Car?> getCarById(String id) async {
    try {
      final response = await _httpClient.get(
        '${ApiConstants.getCarByIdEndpoint}/$id',
        includeAuth: false,
      );

      return _mapToCar(response as Map<String, dynamic>);
    } catch (e) {
      // Fallback to mock data
      try {
        return _mockCars.firstWhere((car) => car.id == id);
      } catch (e) {
        return null;
      }
    }
  }

  // Get cars by type
  Future<List<Car>> getCarsByType(String type) async {
    try {
      final response = await _httpClient.get(
        ApiConstants.getCarsEndpoint,
        queryParameters: {'type': type},
        includeAuth: false,
      );

      // Handle both array and object responses
      List<dynamic> carList = [];
      if (response is List) {
        carList = response as List<dynamic>;
      } else if (response is Map<String, dynamic>) {
        if (response.containsKey('data') && response['data'] is List) {
          carList = response['data'] as List<dynamic>;
        }
      }
      
      return carList.isEmpty
          ? _mockCars.where((car) => car.type == type).toList()
          : carList.map((car) => _mapToCar(car as Map<String, dynamic>)).toList();
    } catch (e) {
      return _mockCars.where((car) => car.type == type).toList();
    }
  }
}
