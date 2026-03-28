import 'package:geocoding/geocoding.dart' as gc;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/location.dart';

class LocationSearchService {
  static const String nominatimBaseUrl = 'https://nominatim.openstreetmap.org/search';

  /// Search for locations by name using Nominatim API with defensive error handling
  static Future<List<Location>> searchLocations(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      final encodedQuery = Uri.encodeComponent(query);
      final url = '$nominatimBaseUrl?q=$encodedQuery&format=json&limit=10&countrycodes=in&addressdetails=1';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'CarRentalApp/1.0',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        
        if (decoded is! List) return [];
        if ((decoded as List).isEmpty) return [];

        final locations = <Location>[];
        final results = decoded as List;
        
        for (var i = 0; i < results.length; i++) {
          try {
            final result = results[i];
            
            // Safely extract values with null-safe operators
            String name = 'Unknown';
            String state = 'India';
            String displayName = 'Unknown';
            double lat = 0.0;
            double lon = 0.0;
            
            // Extract name - try multiple fields
            if (result['name'] is String) {
              name = result['name'] as String;
            } else if (result['address'] is Map) {
              final addr = result['address'] as Map?;
              final city = addr?['city'];
              final town = addr?['town'];
              final village = addr?['village'];
              if (city is String) name = city;
              else if (town is String) name = town;
              else if (village is String) name = village;
            }
            
            // Extract state
            if (result['address'] is Map) {
              final addr = result['address'] as Map?;
              final state_val = addr?['state'];
              final province = addr?['province'];
              if (state_val is String) {
                state = state_val;
              } else if (province is String) {
                state = province;
              }
            }
            
            // Extract coordinates
            final latStr = result['lat'];
            final lonStr = result['lon'];
            if (latStr != null && lonStr != null) {
              lat = double.tryParse(latStr.toString()) ?? 0.0;
              lon = double.tryParse(lonStr.toString()) ?? 0.0;
            }
            
            // Extract display name
            if (result['display_name'] is String) {
              displayName = result['display_name'] as String;
            }

            // Only add valid locations
            if (lat != 0.0 && lon != 0.0) {
              locations.add(Location(
                id: result['osm_id']?.toString() ?? 'unknown',
                name: name,
                city: state,
                latitude: lat,
                longitude: lon,
                address: displayName,
              ));
            }
          } catch (e) {
            print('[LocationSearch] Parse error at $i: $e');
          }
        }

        return locations;
      }
      return [];
    } catch (e) {
      print('[LocationSearch] Error: $e');
      return [];
    }
  }

  /// Calculate distance between two coordinates in kilometers
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    try {
      final distanceInMeters = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
      return distanceInMeters / 1000;
    } catch (e) {
      print('[Distance] Error: $e');
      return 0.0;
    }
  }

  /// Get current location coordinates
  static Future<({double lat, double lon})?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      if (permission == LocationPermission.deniedForever) return null;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return (lat: position.latitude, lon: position.longitude);
    } catch (e) {
      print('[CurrentLocation] Error: $e');
      return null;
    }
  }
}

