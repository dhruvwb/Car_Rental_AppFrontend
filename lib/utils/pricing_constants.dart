// Pricing Constants for Car Rental App (All values in Indian Rupees)

class PricingConstants {
  // Base rate: 1 Rupee per 1 KM
  static const double pricePerKm = 1.0; // RS per KM

  // Daily car rates (can be used as fallback)
  static const double economyDailyRate = 500.0; // RS per day
  static const double sedanDailyRate = 800.0; // RS per day
  static const double suvDailyRate = 1200.0; // RS per day
  static const double premiumDailyRate = 2500.0; // RS per day
  static const double vanDailyRate = 1500.0; // RS per day

  // Insurance costs (per day in Rupees)
  static const Map<String, double> insuranceCosts = {
    'None': 0.0,
    'Basic': 150.0, // RS per day
    'Advanced': 300.0, // RS per day
    'Premium': 500.0, // RS per day
  };

  // Add-on costs (per day in Rupees)
  static const Map<String, double> addOnsCosts = {
    'GPS Device': 75.0, // RS per day
    'Child Seat': 200.0, // RS per day
    'Extra Driver': 300.0, // RS per day
    'WiFi Hotspot': 100.0, // RS per day
  };

  // Tax percentage
  static const double taxPercentage = 0.18; // 18% GST

  // Currency symbol
  static const String currencySymbol = '₹'; // Indian Rupee symbol

  // Format price helper
  static String formatPrice(double price) {
    return '$currencySymbol ${price.toStringAsFixed(2)}';
  }

  // Calculate total price based on distance
  static double calculatePriceFromDistance(double distanceKm) {
    return distanceKm * pricePerKm;
  }
}
