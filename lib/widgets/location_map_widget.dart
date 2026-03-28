import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:provider/provider.dart';
import '../models/index.dart';
import '../providers/index.dart';

class LocationMapWidget extends StatefulWidget {
  final bool isPickupLocation;

  const LocationMapWidget({
    Key? key,
    required this.isPickupLocation,
  }) : super(key: key);

  @override
  State<LocationMapWidget> createState() => _LocationMapWidgetState();
}

class _LocationMapWidgetState extends State<LocationMapWidget> {
  GoogleMapController? _mapController;
  late Location _selectedLocation;
  LatLng? _selectedLatLng;
  String? _selectedAddress;
  bool _isLoading = true;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    final locationProvider = context.read<LocationProvider>();
    if (widget.isPickupLocation) {
      _selectedLocation = locationProvider.pickupLocation ?? Location.predefinedLocations['new-york']!;
    } else {
      _selectedLocation = locationProvider.dropoffLocation ?? Location.predefinedLocations['los-angeles']!;
    }
    _selectedLatLng = LatLng(_selectedLocation.latitude, _selectedLocation.longitude);
    _selectedAddress = _selectedLocation.name;
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      // Request location permission
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      // Get current position
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _selectedLatLng = LatLng(position.latitude, position.longitude);
          _addMarker(_selectedLatLng!);
          _isLoading = false;
        });

        _getAddressFromCoordinates(_selectedLatLng!);

        // Animate camera after a minimal delay to ensure map is ready
        Future.delayed(Duration(milliseconds: 300), () {
          if (mounted && _mapController != null && _selectedLatLng != null) {
            try {
              _mapController!.animateCamera(
                CameraUpdate.newLatLng(_selectedLatLng!),
              );
            } catch (e) {
              print('Error animating camera: $e');
            }
          }
        });
      }
    } catch (e) {
      print('Error initializing map: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _getAddressFromCoordinates(LatLng latlng) async {
    try {
      List<geocoding.Placemark> placemarks = await geocoding.placemarkFromCoordinates(
        latlng.latitude,
        latlng.longitude,
      ).onError((error, stackTrace) {
        print('Geocoding error: $error');
        return [];
      });

      if (placemarks.isNotEmpty && mounted) {
        try {
          geocoding.Placemark place = placemarks.first;
          List<String> addressParts = [];
          
          // Safely add non-null, non-empty parts
          if (place.street?.isNotEmpty ?? false) {
            addressParts.add(place.street!);
          }
          if (place.locality?.isNotEmpty ?? false) {
            addressParts.add(place.locality!);
          }
          if (place.administrativeArea?.isNotEmpty ?? false) {
            addressParts.add(place.administrativeArea!);
          }
          if (place.country?.isNotEmpty ?? false) {
            addressParts.add(place.country!);
          }
          
          String address = addressParts.isNotEmpty 
              ? addressParts.join(', ')
              : '${latlng.latitude.toStringAsFixed(4)}, ${latlng.longitude.toStringAsFixed(4)}';
          
          if (mounted) {
            setState(() {
              _selectedAddress = address;
            });
          }
        } catch (e) {
          print('Error processing placemark: $e');
          if (mounted) {
            setState(() {
              _selectedAddress = '${latlng.latitude.toStringAsFixed(4)}, ${latlng.longitude.toStringAsFixed(4)}';
            });
          }
        }
      } else if (mounted) {
        // No placemarks returned - use coordinates
        setState(() {
          _selectedAddress = '${latlng.latitude.toStringAsFixed(4)}, ${latlng.longitude.toStringAsFixed(4)}';
        });
      }
    } catch (e) {
      print('Error getting address: $e');
      if (mounted) {
        setState(() {
          _selectedAddress = '${latlng.latitude.toStringAsFixed(4)}, ${latlng.longitude.toStringAsFixed(4)}';
        });
      }
    }
  }

  void _addMarker(LatLng position) {
    _markers.clear();
    _markers.add(
      Marker(
        markerId: MarkerId('selected_location'),
        position: position,
        infoWindow: InfoWindow(title: 'Selected Location'),
      ),
    );
  }

  void _onMapTapped(LatLng tappedPoint) {
    setState(() {
      _selectedLatLng = tappedPoint;
      _addMarker(tappedPoint);
    });
    _getAddressFromCoordinates(tappedPoint);
  }

  void _confirmSelection() async {
    if (_selectedLatLng == null || _selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a location')),
      );
      return;
    }

    final location = Location(
      id: DateTime.now().toString(),
      name: _selectedAddress!,
      city: _selectedAddress!.split(',').isNotEmpty ? _selectedAddress!.split(',')[1].trim() : 'Unknown',
      latitude: _selectedLatLng!.latitude,
      longitude: _selectedLatLng!.longitude,
      address: _selectedAddress!,
    );

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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isPickupLocation ? 'Select Pickup Location' : 'Select Dropoff Location'),
        backgroundColor: Color(0xFF0F67B1),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Google Map
          if (!_isLoading && _selectedLatLng != null)
            GoogleMap(
              onMapCreated: (controller) {
                _mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: _selectedLatLng!,
                zoom: 15,
              ),
              onTap: _onMapTapped,
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
            )
          else
            Center(
              child: CircularProgressIndicator(),
            ),

          // Location Details Card at Bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Location',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Color(0xFF0F67B1),
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedAddress ?? 'Select a location',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF111827),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_selectedLatLng != null) ...[
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.pin_drop_outlined,
                          color: Color(0xFF6B7280),
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '${_selectedLatLng!.latitude.toStringAsFixed(4)}, ${_selectedLatLng!.longitude.toStringAsFixed(4)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _confirmSelection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0F67B1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Confirm Location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
