import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/location.dart';
import '../providers/location_provider.dart';

class LocationSelectionScreen extends StatefulWidget {
  final bool isPickupLocation;

  const LocationSelectionScreen({
    Key? key,
    required this.isPickupLocation,
  }) : super(key: key);

  @override
  State<LocationSelectionScreen> createState() => _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  late Location _selectedLocation;
  List<Location> _availableLocations = [];
  late String _searchQuery;

  @override
  void initState() {
    super.initState();
    _searchQuery = '';
    final locationProvider = context.read<LocationProvider>();
    
    if (widget.isPickupLocation) {
      _selectedLocation = locationProvider.pickupLocation ?? Location.predefinedLocations['new-york']!;
    } else {
      _selectedLocation = locationProvider.dropoffLocation ?? Location.predefinedLocations['los-angeles']!;
    }
    
    _availableLocations = Location.predefinedLocations.values.toList();
  }

  void _updateSearch(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  List<Location> _getFilteredLocations() {
    if (_searchQuery.isEmpty) {
      return _availableLocations;
    }
    return _availableLocations
        .where((location) =>
            location.name.toLowerCase().contains(_searchQuery) ||
            location.city.toLowerCase().contains(_searchQuery) ||
            location.address.toLowerCase().contains(_searchQuery))
        .toList();
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
  Widget build(BuildContext context) {
    final filteredLocations = _getFilteredLocations();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isPickupLocation ? 'Select Pickup Location' : 'Select Dropoff Location',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: _updateSearch,
              decoration: InputDecoration(
                hintText: 'Search location...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _updateSearch('');
                        },
                        child: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
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
          ),

          // Locations List
          Expanded(
            child: filteredLocations.isEmpty
                ? Center(
                    child: Text(
                      'No locations found',
                      style: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredLocations.length,
                    itemBuilder: (context, index) {
                      final location = filteredLocations[index];
                      final isSelected = _selectedLocation.id == location.id;

                      return Material(
                        child: InkWell(
                          onTap: () => _selectLocation(location),
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
                                      const SizedBox(height: 4),
                                      Text(
                                        'Coords: ${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFFD1D5DB),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF0F67B1),
                                    size: 24,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
