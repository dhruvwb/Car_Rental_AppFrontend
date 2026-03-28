import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/location.dart';
import '../providers/location_provider.dart';
import '../services/location_search_service.dart';
import 'enquiry_form_screen.dart';

class DynamicLocationSelectionScreen extends StatefulWidget {
  final bool isPickupLocation;

  const DynamicLocationSelectionScreen({
    Key? key,
    required this.isPickupLocation,
  }) : super(key: key);

  @override
  State<DynamicLocationSelectionScreen> createState() =>
      _DynamicLocationSelectionScreenState();
}

class _DynamicLocationSelectionScreenState
    extends State<DynamicLocationSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Location> _suggestions = [];
  bool _isLoading = false;
  Location? _selectedLocation;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final locationProvider = context.read<LocationProvider>();
    
    if (widget.isPickupLocation) {
      _selectedLocation = locationProvider.pickupLocation;
      if (_selectedLocation != null) {
        _searchController.text = _selectedLocation!.name;
      }
    } else {
      _selectedLocation = locationProvider.dropoffLocation;
      if (_selectedLocation != null) {
        _searchController.text = _selectedLocation!.name;
      }
    }
  }

  Future<void> _searchLocations(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('Searching for: $query');
      final results = await LocationSearchService.searchLocations(query);
      
      if (mounted) {
        setState(() {
          _suggestions = results;
          _isLoading = false;
          
          if (results.isEmpty && query.isNotEmpty) {
            _errorMessage = 'No locations found for "$query". Try another search.';
          } else {
            _errorMessage = null;
          }
        });
      }
    } catch (e) {
      print('Search error: $e');
      if (mounted) {
        setState(() {
          _suggestions = [];
          _isLoading = false;
          _errorMessage = 'Search failed: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _navigateBasedOnDistance(Location location) async {
    final locationProvider = context.read<LocationProvider>();
    
    if (widget.isPickupLocation) {
      locationProvider.setPickupLocation(location);
      Navigator.pop(context);
    } else {
      // Calculate distance if we have both locations
      if (locationProvider.pickupLocation != null) {
        final distance = Location.calculateDistance(locationProvider.pickupLocation!, location);
        
        if (distance < 50) {
          // Navigate to enquiry form for short distances
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => EnquiryFormScreen(
                pickupLocation: locationProvider.pickupLocation?.name ?? '',
                dropLocation: location.name,
              ),
            ),
          );
        } else {
          locationProvider.setDropoffLocation(location);
          Navigator.pop(context);
        }
      } else {
        locationProvider.setDropoffLocation(location);
        Navigator.pop(context);
      }
    }
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
                'Search any city or area',
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
      body: Column(
        children: [
          // Search TextField
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              onChanged: _searchLocations,
              decoration: InputDecoration(
                hintText: 'Type city name (e.g., Delhi, Rudrapur, Kicha)',
                prefixIcon: Icon(Icons.location_on, color: Colors.blue[600]),
                suffixIcon: _searchController.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          _searchLocations('');
                        },
                        child: Icon(Icons.clear, color: Colors.grey[400]),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              autofocus: true,
            ),
          ),
          const Divider(height: 0),
          // Suggestions List
          Expanded(
            child: _buildSuggestionsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsList() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Searching locations...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    // Show error message if present
    if (_errorMessage != null && _errorMessage!.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.orange[600]),
              const SizedBox(height: 16),
              Text(
                'Search Failed',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  _searchLocations('');
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_suggestions.isEmpty) {
      if (_searchController.text.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'Start typing to search',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter city name like "Delhi", "Mumbai", "Rudrapur"...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 64, color: Colors.grey[300]),
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
              'Try searching with a different city name',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _suggestions.length,
      itemBuilder: (context, index) {
        final location = _suggestions[index];
        final isSelected = _selectedLocation?.id == location.id;

        return GestureDetector(
          onTap: () => _selectLocation(location),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!),
              ),
              color: isSelected ? Colors.blue[50] : Colors.white,
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
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.name,
                        style: TextStyle(
                          fontSize: 16,
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: Colors.blue[600],
                    size: 24,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
