import 'package:flutter/material.dart';
import 'package:myapp/admin/services/admin_service.dart';
import 'package:myapp/models/car.dart';
import 'package:myapp/models/booking.dart';

class AdminProvider extends ChangeNotifier {
  final _adminService = AdminService();

  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _adminName;
  String? _adminEmail;
  List<Car> _cars = [];
  List<Booking> _pendingBookings = [];
  List<Booking> _allBookings = [];
  List<Map<String, dynamic>> _enquiries = [];
  Map<String, dynamic> _dashboardStats = {};

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get adminName => _adminName;
  String? get adminEmail => _adminEmail;
  List<Car> get cars => _cars;
  List<Booking> get pendingBookings => _pendingBookings;
  List<Booking> get allBookings => _allBookings;
  List<Map<String, dynamic>> get enquiries => _enquiries;
  Map<String, dynamic> get dashboardStats => _dashboardStats;

  /// Admin login
  Future<bool> adminLogin(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _adminService.adminLogin(email, password);
      
      if (result['success']) {
        _isLoggedIn = true;
        _adminName = result['admin']['name'];
        _adminEmail = result['admin']['email'];
        
        // Load initial data
        await loadDashboardData();
        
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      print('Login error: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Admin logout
  Future<void> adminLogout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _adminService.adminLogout();
      _isLoggedIn = false;
      _adminName = null;
      _adminEmail = null;
      _cars = [];
      _pendingBookings = [];
      _allBookings = [];
      _enquiries = [];
      _dashboardStats = {};
    } catch (e) {
      print('Logout error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load dashboard data
  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final stats = await _adminService.getDashboardStats();
      _dashboardStats = stats;

      await loadCars();
      await loadPendingBookings();
      await loadAllBookings();
      await loadEnquiries();

      notifyListeners();
    } catch (e) {
      print('Error loading dashboard data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load all cars
  Future<void> loadCars() async {
    try {
      _cars = await _adminService.getAllCarsForAdmin();
      notifyListeners();
    } catch (e) {
      print('Error loading cars: $e');
    }
  }

  /// Load pending bookings
  Future<void> loadPendingBookings() async {
    try {
      _pendingBookings = await _adminService.getPendingBookings();
      notifyListeners();
    } catch (e) {
      print('Error loading pending bookings: $e');
    }
  }

  /// Load all bookings
  Future<void> loadAllBookings() async {
    try {
      _allBookings = await _adminService.getAllBookings();
      notifyListeners();
    } catch (e) {
      print('Error loading all bookings: $e');
    }
  }

  /// Load all enquiries
  Future<void> loadEnquiries() async {
    try {
      _enquiries = await _adminService.getAllEnquiries();
      notifyListeners();
    } catch (e) {
      print('Error loading enquiries: $e');
    }
  }

  /// Respond to enquiry
  Future<bool> respondToEnquiry({
    required String enquiryId,
    required String adminResponse,
    required double quotedPrice,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _adminService.respondToEnquiry(
        enquiryId: enquiryId,
        adminResponse: adminResponse,
        quotedPrice: quotedPrice,
      );
      // Reload enquiries to reflect the update
      await loadEnquiries();
      notifyListeners();
      return true;
    } catch (e) {
      print('Error responding to enquiry: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add new car
  Future<bool> addCar({
    required String name,
    required String model,
    required int year,
    required String type,
    required double dailyRate,
    required String transmission,
    required String fuel,
    required int seats,
    required int luggage,
    required List<String> features,
    required List<String> images,
    required String registrationNumber,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final car = await _adminService.addCar(
        name: name,
        model: model,
        year: year,
        type: type,
        dailyRate: dailyRate,
        transmission: transmission,
        fuel: fuel,
        seats: seats,
        luggage: luggage,
        features: features,
        images: images,
        registrationNumber: registrationNumber,
      );

      _cars.add(car);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error adding car: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update car
  Future<bool> updateCar({
    required String carId,
    required String name,
    required String model,
    required int year,
    required String type,
    required double dailyRate,
    required String transmission,
    required String fuel,
    required int seats,
    required int luggage,
    required List<String> features,
    required List<String> images,
    required String registrationNumber,
    required bool available,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updatedCar = await _adminService.updateCar(
        carId: carId,
        name: name,
        model: model,
        year: year,
        type: type,
        dailyRate: dailyRate,
        transmission: transmission,
        fuel: fuel,
        seats: seats,
        luggage: luggage,
        features: features,
        images: images,
        registrationNumber: registrationNumber,
        available: available,
      );

      final index = _cars.indexWhere((car) => car.id == carId);
      if (index != -1) {
        _cars[index] = updatedCar;
      }
      notifyListeners();
      return true;
    } catch (e) {
      print('Error updating car: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete car
  Future<bool> deleteCar(String carId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _adminService.deleteCar(carId);
      _cars.removeWhere((car) => car.id == carId);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error deleting car: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Approve booking
  Future<bool> approveBooking(String bookingId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _adminService.approveBooking(bookingId);
      await loadPendingBookings();
      notifyListeners();
      return true;
    } catch (e) {
      print('Error approving booking: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reject booking
  Future<bool> rejectBooking(String bookingId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _adminService.rejectBooking(bookingId);
      await loadPendingBookings();
      notifyListeners();
      return true;
    } catch (e) {
      print('Error rejecting booking: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
