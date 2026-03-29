import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/location.dart';
import '../providers/location_provider.dart';

class EnhancedLocationSelectionScreen extends StatefulWidget {
  final bool isPickupLocation;

  const EnhancedLocationSelectionScreen({
    Key? key,
    required this.isPickupLocation,
  }) : super(key: key);

  @override
  State<EnhancedLocationSelectionScreen> createState() =>
      _EnhancedLocationSelectionScreenState();
}

class _EnhancedLocationSelectionScreenState
    extends State<EnhancedLocationSelectionScreen> {
  late Location _selectedLocation;
  List<Location> _suggestedLocations = [];
  final TextEditingController _searchController = TextEditingController();
  bool _showMapView = false; // Default to list view since we don't have Google Maps

  @override
  void initState() {
    super.initState();
    final locationProvider = context.read<LocationProvider>();

    if (widget.isPickupLocation) {
      _selectedLocation = locationProvider.pickupLocation ??
          Location.predefinedLocations['delhi']!;
    } else {
      _selectedLocation = locationProvider.dropoffLocation ??
          Location.predefinedLocations['mumbai']!;
    }

    _suggestedLocations = Location.predefinedLocations.values.toList();
  }

  void _addMarker(Location location) {
    // Map view not available in free version
  }

  void _onMapTapped(double lat, double lon) {
    // Find the closest predefined location to the tapped point
    double closestDistance = double.infinity;
    Location closestLocation =
        Location.predefinedLocations.values.first;

    for (var location in Location.predefinedLocations.values) {
      final distance = _calculateDistance(
        lat,
        lon,
        location.latitude,
        location.longitude,
      );

      if (distance < closestDistance) {
        closestDistance = distance;
        closestLocation = location;
      }
    }

    setState(() {
      _selectedLocation = closestLocation;
      _searchController.text = closestLocation.name;
    });
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371; // Earth's radius in km
    final double dLat = (lat2 - lat1) * 3.14159 / 180;
    final double dLon = (lon2 - lon1) * 3.14159 / 180;
    return R * 2 * 0.5; // Simplified for now
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _suggestedLocations = Location.predefinedLocations.values.toList();
      } else {
        _suggestedLocations = Location.predefinedLocations.values
            .where((location) =>
                location.name.toLowerCase().contains(query.toLowerCase()) ||
                location.city.toLowerCase().contains(query.toLowerCase()) ||
                location.address.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _selectLocation(Location location) {
    final locationProvider = context.read<LocationProvider>();

    if (widget.isPickupLocation) {
      locationProvider.setPickupLocation(location);
    } else {
      locationProvider.setDropoffLocation(location);
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isPickupLocation
              ? 'Select Pickup Location'
              : 'Select Dropoff Location',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Column(
        children: [
          // Search Bar with Toggle
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search TextField
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search location...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                            child: const Icon(Icons.clear),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF0F67B1),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // View Toggle Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() => _showMapView = true);
                        },
                        icon: const Icon(Icons.map),
                        label: const Text('Map View'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _showMapView
                              ? const Color(0xFF0F67B1)
                              : Colors.grey[300],
                          foregroundColor:
                              _showMapView ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() => _showMapView = false);
                        },
                        icon: const Icon(Icons.list),
                        label: const Text('List View'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: !_showMapView
                              ? const Color(0xFF0F67B1)
                              : Colors.grey[300],
                          foregroundColor:
                              !_showMapView ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Divider
          const Divider(height: 0),
          // Map or List View
          Expanded(
            child: _showMapView ? _buildMapView() : _buildListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map, size: 64, color: Color(0xFF9CA3AF)),
          SizedBox(height: 16),
          Text(
            'Map view available in premium version',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Use list view to select a location',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return _suggestedLocations.isEmpty
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No locations found for "${_searchController.text}"',
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
        : ListView.builder(
            itemCount: _suggestedLocations.length,
            itemBuilder: (context, index) {
              final location = _suggestedLocations[index];
              final isSelected = _selectedLocation.id == location.id;

              return Material(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedLocation = location;
                      _searchController.text = location.name;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFFE5E7EB),
                        ),
                      ),
                      color: isSelected
                          ? Color(0xFF0F67B1).withOpacity(0.05)
                          : Colors.white,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? Color(0xFF0F67B1)
                                : Color(0xFFE5E7EB),
                          ),
                          child: Icon(
                            Icons.location_on,
                            size: 20,
                            color: isSelected
                                ? Colors.white
                                : Color(0xFF9CA3AF),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                location.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                location.address,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  Color(0xFF0F67B1).withOpacity(0.1),
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Color(0xFF0F67B1),
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
  }
}
