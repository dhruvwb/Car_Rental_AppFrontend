import 'dart:math' as math;

class Location {
  final String id;
  final String name;
  final String city;
  final double latitude;
  final double longitude;
  final String address;

  Location({
    required this.id,
    required this.name,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  static final Map<String, Location> predefinedLocations = {
    'delhi': Location(
      id: 'delhi',
      name: 'New Delhi',
      city: 'Delhi',
      latitude: 28.7041,
      longitude: 77.1025,
      address: 'New Delhi, Delhi, India',
    ),
    'mumbai': Location(
      id: 'mumbai',
      name: 'Mumbai',
      city: 'Mumbai',
      latitude: 19.0760,
      longitude: 72.8777,
      address: 'Mumbai, Maharashtra, India',
    ),
    'bangalore': Location(
      id: 'bangalore',
      name: 'Bangalore',
      city: 'Bangalore',
      latitude: 12.9716,
      longitude: 77.5946,
      address: 'Bangalore, Karnataka, India',
    ),
    'hyderabad': Location(
      id: 'hyderabad',
      name: 'Hyderabad',
      city: 'Hyderabad',
      latitude: 17.3850,
      longitude: 78.4867,
      address: 'Hyderabad, Telangana, India',
    ),
    'pune': Location(
      id: 'pune',
      name: 'Pune',
      city: 'Pune',
      latitude: 18.5204,
      longitude: 73.8567,
      address: 'Pune, Maharashtra, India',
    ),
    'kolkata': Location(
      id: 'kolkata',
      name: 'Kolkata',
      city: 'Kolkata',
      latitude: 22.5726,
      longitude: 88.3639,
      address: 'Kolkata, West Bengal, India',
    ),
    'chennai': Location(
      id: 'chennai',
      name: 'Chennai',
      city: 'Chennai',
      latitude: 13.0827,
      longitude: 80.2707,
      address: 'Chennai, Tamil Nadu, India',
    ),
    'jaipur': Location(
      id: 'jaipur',
      name: 'Jaipur',
      city: 'Jaipur',
      latitude: 26.9124,
      longitude: 75.7873,
      address: 'Jaipur, Rajasthan, India',
    ),
    'ahmedabad': Location(
      id: 'ahmedabad',
      name: 'Ahmedabad',
      city: 'Ahmedabad',
      latitude: 23.0225,
      longitude: 72.5714,
      address: 'Ahmedabad, Gujarat, India',
    ),
    'lucknow': Location(
      id: 'lucknow',
      name: 'Lucknow',
      city: 'Lucknow',
      latitude: 26.8467,
      longitude: 80.9462,
      address: 'Lucknow, Uttar Pradesh, India',
    ),
  };

  // Calculate distance between two locations using Haversine formula
  static double calculateDistance(Location start, Location end) {
    const R = 6371; // Earth's radius in kilometers
    final lat1Rad = start.latitude * math.pi / 180;
    final lat2Rad = end.latitude * math.pi / 180;
    final deltaLatRad = (end.latitude - start.latitude) * math.pi / 180;
    final deltaLonRad = (end.longitude - start.longitude) * math.pi / 180;

    // Simplified distance calculation using Pythagorean approximation
    final dLat = (end.latitude - start.latitude);
    final dLon = (end.longitude - start.longitude);
    final distance = math.sqrt(dLat * dLat + dLon * dLon) * 111; // Approximate km conversion
    return distance.abs();
  }
}
