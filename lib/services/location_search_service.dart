import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/location.dart';
import 'dart:math' as math;

class LocationSearchService {
  static const String _nominatimBaseUrl = 'https://nominatim.openstreetmap.org';

  /// Search for locations using Nominatim API
  static Future<List<Location>> searchLocations(String query) async {
    if (query.isEmpty) {
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse(
          '$_nominatimBaseUrl/search?q=$query&format=json&limit=10',
        ),
        headers: {
          'User-Agent': 'CarRental/1.0',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> results = jsonDecode(response.body);
        return results
            .map((json) => Location(
                  id: json['osm_id']?.toString() ?? 'loc_${DateTime.now().millisecondsSinceEpoch}',
                  name: json['display_name'] ?? 'Unknown',
                  latitude: double.parse(json['lat'] ?? '0'),
                  longitude: double.parse(json['lon'] ?? '0'),
                  city: _extractCity(json['display_name'] ?? ''),
                  address: json['display_name'] ?? 'Unknown',
                  state: _extractState(json['display_name'] ?? ''),
                ))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error searching locations: $e');
      return [];
    }
  }

  /// Calculate distance between two coordinates using Haversine formula
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double R = 6371; // Earth's radius in kilometers

    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final double distance = R * c;

    return distance;
  }

  static double _toRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  static String _extractCity(String displayName) {
    // Extract city name from display_name
    final parts = displayName.split(',');
    if (parts.isNotEmpty) {
      // Get the second or first part as city
      final city = parts.length > 1 ? parts[1].trim() : parts[0].trim();
      return city;
    }
    return displayName;
  }

  static String _extractState(String displayName) {
    // Extract state name from display_name
    final parts = displayName.split(',');
    if (parts.length >= 3) {
      return parts[2].trim();
    } else if (parts.length >= 2) {
      return parts[1].trim();
    }
    return '';
  }
}
