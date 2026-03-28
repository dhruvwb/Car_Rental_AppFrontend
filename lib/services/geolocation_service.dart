import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import '../models/location.dart';

class GeolocationService {
  static const String _nominatimUrl = 'https://nominatim.openstreetmap.org';
  
  /// Get address from latitude and longitude using Nominatim (FREE - No API key needed)
  static Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final String url =
          '$_nominatimUrl/reverse?format=json&lat=$latitude&lon=$longitude';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'CarRentalApp/1.0', // Nominatim requires this header
        },
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () => http.Response('timeout', 408),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final address = jsonResponse['address'];
        
        // Build readable address from components
        final city = address['city'] ?? address['town'] ?? '';
        final state = address['state'] ?? '';
        final country = address['country'] ?? '';
        final roadName = address['road'] ?? '';
        
        String fullAddress = '';
        if (roadName.isNotEmpty) fullAddress += '$roadName, ';
        if (city.isNotEmpty) fullAddress += '$city, ';
        if (state.isNotEmpty) fullAddress += '$state, ';
        if (country.isNotEmpty) fullAddress += country;
        
        return fullAddress.isNotEmpty 
          ? fullAddress 
          : '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
      }
      return null;
    } catch (e) {
      print('Error getting address: $e');
      return null;
    }
  }

  /// Search for locations by name using Nominatim (FREE)
  static Future<List<Location>> searchLocations(String query) async {
    try {
      final String url =
          '$_nominatimUrl/search?q=$query&format=json&limit=5';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'CarRentalApp/1.0',
        },
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () => http.Response('timeout', 408),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);
        return jsonResponse.map((item) {
          return Location(
            id: item['osm_id'].toString(),
            name: item['name'] ?? 'Unknown',
            city: item['address']?['city'] ?? 'Unknown',
            latitude: double.parse(item['lat']),
            longitude: double.parse(item['lon']),
            address: item['display_name'] ?? item['name'] ?? 'Unknown',
          );
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error searching locations: $e');
      return [];
    }
  }

  /// Calculate distance between two locations in kilometers
  static double calculateDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double R = 6371; // Earth's radius in km
    final double dLat = _toRad(lat2 - lat1);
    final double dLon = _toRad(lon2 - lon1);
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  static double _toRad(double degrees) {
    return degrees * math.pi / 180;
  }
}
