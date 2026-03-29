import 'package:flutter/material.dart';
import '../../models/index.dart';
import '../services/index.dart';

class CarProvider extends ChangeNotifier {
  final CarService _carService = CarService();

  List<Car> _allCars = [];
  List<Car> _searchResults = [];
  Car? _selectedCar;
  bool _isLoading = false;

  // Getters
  List<Car> get allCars => _allCars;
  List<Car> get searchResults => _searchResults;
  List<Car> get filteredCars => _searchResults.isNotEmpty ? _searchResults : _allCars;
  Car? get selectedCar => _selectedCar;
  bool get isLoading => _isLoading;

  // Fetch all cars
  Future<void> getAllCars() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allCars = await _carService.getAllCars();
    } catch (e) {
      print('Error fetching cars: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search cars
  Future<void> searchCars({
    required String location,
    required DateTime pickupDate,
    required DateTime dropoffDate,
    String? carType,
    double? minPrice,
    double? maxPrice,
    double? minRating,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _searchResults = await _carService.searchCars(
        location: location,
        pickupDate: pickupDate,
        dropoffDate: dropoffDate,
        carType: carType,
        minPrice: minPrice,
        maxPrice: maxPrice,
        minRating: minRating,
      );
    } catch (e) {
      print('Error searching cars: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get car by ID
  Future<void> getCarById(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      _selectedCar = await _carService.getCarById(id);
    } catch (e) {
      print('Error fetching car: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get cars by type
  Future<List<Car>> getCarsByType(String type) async {
    try {
      return await _carService.getCarsByType(type);
    } catch (e) {
      print('Error fetching cars by type: $e');
      return [];
    }
  }

  // Clear search results
  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }
}
