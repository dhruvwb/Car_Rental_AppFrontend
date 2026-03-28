import 'package:flutter/material.dart';
import '../models/index.dart';
import '../utils/pricing_constants.dart';

class LocationProvider extends ChangeNotifier {
  Location? _pickupLocation;
  Location? _dropoffLocation;
  double _distanceKm = 0;
  double _pricePerKm = PricingConstants.pricePerKm; // 1 RS per KM
  double _totalPrice = 0;

  // Getters
  Location? get pickupLocation => _pickupLocation;
  Location? get dropoffLocation => _dropoffLocation;
  double get distanceKm => _distanceKm;
  double get pricePerKm => _pricePerKm;
  double get totalPrice => _totalPrice;
  
  // Formatted price getter
  String get formattedTotalPrice => PricingConstants.formatPrice(_totalPrice);

  // Setters with automatic price calculation
  void setPickupLocation(Location location) {
    _pickupLocation = location;
    _calculatePrice();
    notifyListeners();
  }

  void setDropoffLocation(Location location) {
    _dropoffLocation = location;
    _calculatePrice();
    notifyListeners();
  }

  void setPricePerKm(double price) {
    _pricePerKm = price;
    _calculatePrice();
    notifyListeners();
  }

  void setDistance(double distanceKm) {
    _distanceKm = distanceKm;
    _calculatePrice();
    notifyListeners();
  }

  Future<double> calculateDistance(Location destination) async {
    if (_pickupLocation != null) {
      return Location.calculateDistance(_pickupLocation!, destination);
    }
    return 0;
  }

  void _calculatePrice() {
    if (_pickupLocation != null && _dropoffLocation != null) {
      _distanceKm = Location.calculateDistance(_pickupLocation!, _dropoffLocation!);
      _totalPrice = _distanceKm * _pricePerKm;
    } else {
      _distanceKm = 0;
      _totalPrice = 0;
    }
  }

  void clearLocations() {
    _pickupLocation = null;
    _dropoffLocation = null;
    _distanceKm = 0;
    _totalPrice = 0;
    notifyListeners();
  }
}
