import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/location.dart';
import '../providers/location_provider.dart';

class SimpleLocationSelectionScreen extends StatefulWidget {
  final bool isPickupLocation;

  const SimpleLocationSelectionScreen({
    Key? key,
    required this.isPickupLocation,
  }) : super(key: key);

  @override
  State<SimpleLocationSelectionScreen> createState() =>
      _SimpleLocationSelectionScreenState();
}

class _SimpleLocationSelectionScreenState
    extends State<SimpleLocationSelectionScreen> {
  late Location _selectedLocation;
  List<Location> _suggestedLocations = [];
  final TextEditingController _searchController = TextEditingController();

  // Comprehensive Indian cities and states for flexible search
  static final indianCitiesAndStates = [
    // Northern Region Cities
    Location(id: 'delhi-city', name: 'Delhi', city: 'Delhi', latitude: 28.7041, longitude: 77.1025, address: 'Delhi, India'),
    Location(id: 'noida-city', name: 'Noida', city: 'Noida', latitude: 28.5721, longitude: 77.3565, address: 'Noida, Uttar Pradesh, India'),
    Location(id: 'meerut-city', name: 'Meerut', city: 'Meerut', latitude: 28.9845, longitude: 77.7064, address: 'Meerut, Uttar Pradesh, India'),
    Location(id: 'muradabad-city', name: 'Muradabad', city: 'Muradabad', latitude: 28.8385, longitude: 77.7597, address: 'Muradabad, Uttar Pradesh, India'),
    Location(id: 'rampur-city', name: 'Rampur', city: 'Rampur', latitude: 28.8133, longitude: 78.8151, address: 'Rampur, Uttar Pradesh, India'),
    Location(id: 'ghaziabad-city', name: 'Ghaziabad', city: 'Ghaziabad', latitude: 28.6692, longitude: 77.4538, address: 'Ghaziabad, Uttar Pradesh, India'),
    Location(id: 'lucknow-city', name: 'Lucknow', city: 'Lucknow', latitude: 26.8467, longitude: 80.9462, address: 'Lucknow, Uttar Pradesh, India'),
    Location(id: 'kanpur-city', name: 'Kanpur', city: 'Kanpur', latitude: 26.4499, longitude: 80.3319, address: 'Kanpur, Uttar Pradesh, India'),
    Location(id: 'agra-city', name: 'Agra', city: 'Agra', latitude: 27.1767, longitude: 78.0081, address: 'Agra, Uttar Pradesh, India'),
    Location(id: 'gurugram-city', name: 'Gurugram', city: 'Gurugram', latitude: 28.4595, longitude: 77.0266, address: 'Gurugram, Haryana, India'),
    Location(id: 'faridabad-city', name: 'Faridabad', city: 'Faridabad', latitude: 28.4089, longitude: 77.3178, address: 'Faridabad, Haryana, India'),
    Location(id: 'chandigarh-city', name: 'Chandigarh', city: 'Chandigarh', latitude: 30.7333, longitude: 76.7794, address: 'Chandigarh, India'),
    Location(id: 'amritsar-city', name: 'Amritsar', city: 'Amritsar', latitude: 31.6340, longitude: 74.8723, address: 'Amritsar, Punjab, India'),
    Location(id: 'ludhiana-city', name: 'Ludhiana', city: 'Ludhiana', latitude: 30.9010, longitude: 75.8573, address: 'Ludhiana, Punjab, India'),
    Location(id: 'jalandhar-city', name: 'Jalandhar', city: 'Jalandhar', latitude: 31.7260, longitude: 75.5762, address: 'Jalandhar, Punjab, India'),
    Location(id: 'shimla-city', name: 'Shimla', city: 'Shimla', latitude: 31.7775, longitude: 77.1577, address: 'Shimla, Himachal Pradesh, India'),
    Location(id: 'manali-city', name: 'Manali', city: 'Manali', latitude: 32.2396, longitude: 77.1887, address: 'Manali, Himachal Pradesh, India'),
    Location(id: 'srinagar-city', name: 'Srinagar', city: 'Srinagar', latitude: 34.0837, longitude: 74.7973, address: 'Srinagar, Jammu & Kashmir, India'),
    Location(id: 'leh-city', name: 'Leh', city: 'Leh', latitude: 34.1526, longitude: 77.5771, address: 'Leh, Ladakh, India'),
    
    // Western Region Cities
    Location(id: 'mumbai-city', name: 'Mumbai', city: 'Mumbai', latitude: 19.0760, longitude: 72.8777, address: 'Mumbai, Maharashtra, India'),
    Location(id: 'pune-city', name: 'Pune', city: 'Pune', latitude: 18.5204, longitude: 73.8567, address: 'Pune, Maharashtra, India'),
    Location(id: 'nagpur-city', name: 'Nagpur', city: 'Nagpur', latitude: 21.1458, longitude: 79.0882, address: 'Nagpur, Maharashtra, India'),
    Location(id: 'aurangabad-city', name: 'Aurangabad', city: 'Aurangabad', latitude: 19.8762, longitude: 75.3433, address: 'Aurangabad, Maharashtra, India'),
    Location(id: 'ahmedabad-city', name: 'Ahmedabad', city: 'Ahmedabad', latitude: 23.0225, longitude: 72.5714, address: 'Ahmedabad, Gujarat, India'),
    Location(id: 'surat-city', name: 'Surat', city: 'Surat', latitude: 21.1695, longitude: 72.8295, address: 'Surat, Gujarat, India'),
    Location(id: 'vadodara-city', name: 'Vadodara', city: 'Vadodara', latitude: 22.3072, longitude: 73.1812, address: 'Vadodara, Gujarat, India'),
    Location(id: 'rajkot-city', name: 'Rajkot', city: 'Rajkot', latitude: 22.3039, longitude: 70.8022, address: 'Rajkot, Gujarat, India'),
    Location(id: 'jaipur-city', name: 'Jaipur', city: 'Jaipur', latitude: 26.9124, longitude: 75.7873, address: 'Jaipur, Rajasthan, India'),
    Location(id: 'jodhpur-city', name: 'Jodhpur', city: 'Jodhpur', latitude: 26.2389, longitude: 73.0243, address: 'Jodhpur, Rajasthan, India'),
    Location(id: 'udaipur-city', name: 'Udaipur', city: 'Udaipur', latitude: 24.5854, longitude: 73.7125, address: 'Udaipur, Rajasthan, India'),
    Location(id: 'kota-city', name: 'Kota', city: 'Kota', latitude: 25.2138, longitude: 75.8648, address: 'Kota, Rajasthan, India'),

    // Southern Region Cities
    Location(id: 'bangalore-city', name: 'Bengaluru', city: 'Bengaluru', latitude: 12.9716, longitude: 77.5946, address: 'Bengaluru, Karnataka, India'),
    Location(id: 'hyderabad-city', name: 'Hyderabad', city: 'Hyderabad', latitude: 17.3850, longitude: 78.4867, address: 'Hyderabad, Telangana, India'),
    Location(id: 'mysore-city', name: 'Mysore', city: 'Mysore', latitude: 12.2958, longitude: 76.6394, address: 'Mysore, Karnataka, India'),
    Location(id: 'coimbatore-city', name: 'Coimbatore', city: 'Coimbatore', latitude: 11.0026, longitude: 76.9969, address: 'Coimbatore, Tamil Nadu, India'),
    Location(id: 'madras-city', name: 'Chennai', city: 'Chennai', latitude: 13.0827, longitude: 80.2707, address: 'Chennai, Tamil Nadu, India'),
    Location(id: 'salem-city', name: 'Salem', city: 'Salem', latitude: 11.6643, longitude: 78.1460, address: 'Salem, Tamil Nadu, India'),
    Location(id: 'kochi-city', name: 'Kochi', city: 'Kochi', latitude: 9.9312, longitude: 76.2673, address: 'Kochi, Kerala, India'),
    Location(id: 'thiruvananthapuram-city', name: 'Thiruvananthapuram', city: 'Thiruvananthapuram', latitude: 8.5241, longitude: 76.9366, address: 'Thiruvananthapuram, Kerala, India'),
    Location(id: 'visakhapatnam-city', name: 'Visakhapatnam', city: 'Visakhapatnam', latitude: 17.6869, longitude: 83.2185, address: 'Visakhapatnam, Andhra Pradesh, India'),
    Location(id: 'vijayawada-city', name: 'Vijayawada', city: 'Vijayawada', latitude: 16.5062, longitude: 80.6480, address: 'Vijayawada, Andhra Pradesh, India'),

    // Central & Eastern Region Cities
    Location(id: 'kolkata-city', name: 'Kolkata', city: 'Kolkata', latitude: 22.5726, longitude: 88.3639, address: 'Kolkata, West Bengal, India'),
    Location(id: 'bhopal-city', name: 'Bhopal', city: 'Bhopal', latitude: 23.1815, longitude: 77.4104, address: 'Bhopal, Madhya Pradesh, India'),
    Location(id: 'indore-city', name: 'Indore', city: 'Indore', latitude: 22.7196, longitude: 75.8577, address: 'Indore, Madhya Pradesh, India'),
    Location(id: 'jabalpur-city', name: 'Jabalpur', city: 'Jabalpur', latitude: 23.1815, longitude: 79.9864, address: 'Jabalpur, Madhya Pradesh, India'),
    Location(id: 'patna-city', name: 'Patna', city: 'Patna', latitude: 25.5941, longitude: 85.1376, address: 'Patna, Bihar, India'),
    Location(id: 'guwahati-city', name: 'Guwahati', city: 'Guwahati', latitude: 26.1445, longitude: 91.7362, address: 'Guwahati, Assam, India'),

    // States
    Location(id: 'haryana-state', name: 'Haryana', city: 'Haryana', latitude: 29.0588, longitude: 77.0745, address: 'Haryana, India'),
    Location(id: 'uttarakhand-state', name: 'Uttarakhand', city: 'Uttarakhand', latitude: 30.0668, longitude: 79.0193, address: 'Uttarakhand, India'),
    Location(id: 'punjab-state', name: 'Punjab', city: 'Punjab', latitude: 31.1471, longitude: 75.3412, address: 'Punjab, India'),
    Location(id: 'himachal-state', name: 'Himachal Pradesh', city: 'Himachal Pradesh', latitude: 31.7433, longitude: 77.1205, address: 'Himachal Pradesh, India'),
    Location(id: 'jammu-kashmir-state', name: 'Jammu & Kashmir', city: 'Jammu & Kashmir', latitude: 34.2996, longitude: 77.5770, address: 'Jammu & Kashmir, India'),
    Location(id: 'ladakh-state', name: 'Ladakh', city: 'Ladakh', latitude: 34.1526, longitude: 77.5771, address: 'Ladakh, India'),
    Location(id: 'uttar-pradesh-state', name: 'Uttar Pradesh', city: 'Uttar Pradesh', latitude: 26.8467, longitude: 80.9462, address: 'Uttar Pradesh, India'),
    Location(id: 'maharashtra-state', name: 'Maharashtra', city: 'Maharashtra', latitude: 19.7515, longitude: 75.7139, address: 'Maharashtra, India'),
    Location(id: 'gujarat-state', name: 'Gujarat', city: 'Gujarat', latitude: 22.2587, longitude: 71.1924, address: 'Gujarat, India'),
    Location(id: 'rajasthan-state', name: 'Rajasthan', city: 'Rajasthan', latitude: 27.0238, longitude: 74.2179, address: 'Rajasthan, India'),
    Location(id: 'karnataka-state', name: 'Karnataka', city: 'Karnataka', latitude: 15.3173, longitude: 75.7139, address: 'Karnataka, India'),
    Location(id: 'telangana-state', name: 'Telangana', city: 'Telangana', latitude: 18.1124, longitude: 79.0193, address: 'Telangana, India'),
    Location(id: 'andhra-pradesh-state', name: 'Andhra Pradesh', city: 'Andhra Pradesh', latitude: 15.9129, longitude: 79.7400, address: 'Andhra Pradesh, India'),
    Location(id: 'tamil-nadu-state', name: 'Tamil Nadu', city: 'Tamil Nadu', latitude: 11.1271, longitude: 79.2804, address: 'Tamil Nadu, India'),
    Location(id: 'kerala-state', name: 'Kerala', city: 'Kerala', latitude: 9.7489, longitude: 76.6335, address: 'Kerala, India'),
    Location(id: 'west-bengal-state', name: 'West Bengal', city: 'West Bengal', latitude: 24.8615, longitude: 88.2288, address: 'West Bengal, India'),
    Location(id: 'bihar-state', name: 'Bihar', city: 'Bihar', latitude: 25.2441, longitude: 85.3829, address: 'Bihar, India'),
    Location(id: 'jharkhand-state', name: 'Jharkhand', city: 'Jharkhand', latitude: 23.6102, longitude: 85.2799, address: 'Jharkhand, India'),
    Location(id: 'madhya-pradesh-state', name: 'Madhya Pradesh', city: 'Madhya Pradesh', latitude: 22.9068, longitude: 78.1864, address: 'Madhya Pradesh, India'),
    Location(id: 'assam-state', name: 'Assam', city: 'Assam', latitude: 26.2006, longitude: 92.9376, address: 'Assam, India'),
  ];

  @override
  void initState() {
    super.initState();
    final locationProvider = context.read<LocationProvider>();

    if (widget.isPickupLocation) {
      _selectedLocation = locationProvider.pickupLocation ??
          indianCitiesAndStates[0];
    } else {
      _selectedLocation = locationProvider.dropoffLocation ??
          indianCitiesAndStates[1];
    }

    _searchController.text = _selectedLocation.address;
    _suggestedLocations = indianCitiesAndStates;
  }

  void _onLocationSelected(Location location) {
    setState(() {
      _selectedLocation = location;
      _searchController.text = location.address;
    });
  }

  void _searchLocations(String query) {
    if (query.isEmpty) {
      setState(() {
        _suggestedLocations = indianCitiesAndStates;
      });
      return;
    }

    final lowerQuery = query.toLowerCase();

    // Separate matches into two categories:
    // 1. Matches that START with the query (higher priority)
    // 2. Matches that CONTAIN the query (lower priority)
    final startsWith = <Location>[];
    final contains = <Location>[];

    for (var loc in indianCitiesAndStates) {
      final nameMatch = loc.name.toLowerCase();
      final cityMatch = loc.city.toLowerCase();
      
      // Check if name or city starts with query
      if (nameMatch.startsWith(lowerQuery) || cityMatch.startsWith(lowerQuery)) {
        startsWith.add(loc);
      }
      // Check if name, city, or address contains query (but doesn't start with it)
      else if (nameMatch.contains(lowerQuery) ||
               cityMatch.contains(lowerQuery) ||
               loc.address.toLowerCase().contains(lowerQuery)) {
        contains.add(loc);
      }
    }

    // Combine: priority matches first, then remaining matches
    final filtered = [...startsWith, ...contains];

    setState(() {
      _suggestedLocations = filtered.isNotEmpty ? filtered : [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isPickupLocation ? 'Pickup Location' : 'Dropoff Location',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Select city or state',
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Box
              TextField(
                controller: _searchController,
                onChanged: _searchLocations,
                decoration: InputDecoration(
                  hintText: 'Search city or state...',
                  prefixIcon: Icon(Icons.location_on, color: Colors.blue[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFE5E7EB),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue[600]!),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 20),

              // Selected Location Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Location',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedLocation.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 16, color: Color(0xFF6B7280)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _selectedLocation.address,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Available Locations List
              Text(
                'All Locations',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 12),
              if (_suggestedLocations.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      children: [
                        Icon(Icons.location_off, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No locations found',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try searching for a different city or state',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _suggestedLocations.length,
                itemBuilder: (context, index) {
                  final location = _suggestedLocations[index];
                  final isSelected = location.id == _selectedLocation.id;

                  return GestureDetector(
                    onTap: () => _onLocationSelected(location),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue[50] : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Colors.blue[400]!
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? Colors.blue[600]
                                  : Colors.grey[300],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  location.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  location.address,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(Icons.check_circle,
                                color: Colors.blue[600],
                                size: 24),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Done Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final locationProvider =
                        context.read<LocationProvider>();

                    if (widget.isPickupLocation) {
                      locationProvider.setPickupLocation(_selectedLocation);
                    } else {
                      locationProvider.setDropoffLocation(_selectedLocation);
                    }

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Confirm Location',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
