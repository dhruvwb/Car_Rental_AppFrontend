import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/index.dart';
import '../../widgets/index.dart';
import '../../models/car.dart';
import '../../models/location.dart';
import '../../utils/pricing_constants.dart';
import 'search_results_screen.dart';
import 'login_screen.dart';
import 'dynamic_location_selection_screen.dart';
import 'enquiry_form_screen.dart';
import '../services/location_search_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedLocation;
  DateTime? _pickupDate;
  DateTime? _dropoffDate;
  double? _distanceInKm;

  final List<String> _locations = [
    'New York',
    'Los Angeles',
    'Chicago',
    'Houston',
    'Phoenix',
    'San Francisco',
    'Miami',
    'Boston',
  ];

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _checkAuthentication();
    // });
  }

  // void _checkAuthentication() {
  //   final authProvider = Provider.of<AuthProvider>(context, listen: false);
  //   if (!authProvider.isLoggedIn) {
  //     Navigator.of(context).pushReplacementNamed('/login');
  //   }
  // }

  void _selectPickupDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (selected != null) {
      setState(() {
        _pickupDate = selected;
      });
    }
  }

  Future<void> _calculateDistance() async {
    final locationProvider = context.read<LocationProvider>();
    
    if (locationProvider.pickupLocation != null && 
        locationProvider.dropoffLocation != null) {
      
      final pickup = locationProvider.pickupLocation!;
      final dropoff = locationProvider.dropoffLocation!;
      
      // Calculate distance using coordinates
      final distance = LocationSearchService.calculateDistance(
        pickup.latitude,
        pickup.longitude,
        dropoff.latitude,
        dropoff.longitude,
      );
      
      setState(() {
        _distanceInKm = distance;
      });
      
      // Update the location provider with distance
      locationProvider.setDistance(distance);
    }
  }

  void _selectDropoffDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _pickupDate ?? DateTime.now().add(Duration(days: 1)),
      firstDate: _pickupDate ?? DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (selected != null) {
      setState(() {
        _dropoffDate = selected;
      });
    }
  }

  void _searchCars() async {
    final locationProvider = context.read<LocationProvider>();
    
    if (locationProvider.pickupLocation == null || 
        locationProvider.dropoffLocation == null || 
        _pickupDate == null || 
        _dropoffDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    // Check if within same city
    final pickup = locationProvider.pickupLocation!;
    final dropoff = locationProvider.dropoffLocation!;
    final isSameCity = pickup.city.toLowerCase() == dropoff.city.toLowerCase();

    if (isSameCity) {
      // Show enquiry form for within-city requests
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EnquiryFormScreen(
            pickupLocation: pickup.name,
            dropLocation: dropoff.name,
          ),
        ),
      );
    } else {
      // Show vehicles for cross-city requests
      final carProvider = context.read<CarProvider>();
      await carProvider.searchCars(
        location: pickup.name,
        pickupDate: _pickupDate!,
        dropoffDate: _dropoffDate!,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultsScreen(
            location: pickup.name,
            pickupDate: _pickupDate!,
            dropoffDate: _dropoffDate!,
          ),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.directions_car, color: Color(0xFF0F67B1), size: 28),
            SizedBox(width: 12),
            Text(
              'CarRent',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 24,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 28, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Find Your Perfect Ride',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Easy, fast, and affordable car rentals',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),

              // Search Card
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF000000).withOpacity(0.06),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pickup Location
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, color: Color(0xFF0F67B1), size: 18),
                            SizedBox(width: 8),
                            Text('Pickup Location', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                          ],
                        ),
                        SizedBox(height: 10),
                        Consumer<LocationProvider>(
                          builder: (context, locationProvider, _) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const DynamicLocationSelectionScreen(isPickupLocation: true),
                                  ),
                                ).then((_) => _calculateDistance());
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Color(0xFFE5E7EB)),
                                  borderRadius: BorderRadius.circular(12),
                                  color: Color(0xFFF9FAFB),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        locationProvider.pickupLocation?.name ?? 'Type a city name...',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: locationProvider.pickupLocation != null ? Color(0xFF1F2937) : Color(0xFF9CA3AF),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.location_on_outlined, color: Color(0xFF0F67B1), size: 18),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Dropoff Location
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Color(0xFF059669), size: 18),
                            SizedBox(width: 8),
                            Text('Dropoff Location', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                          ],
                        ),
                        SizedBox(height: 10),
                        Consumer<LocationProvider>(
                          builder: (context, locationProvider, _) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const DynamicLocationSelectionScreen(isPickupLocation: false),
                                  ),
                                ).then((_) => _calculateDistance());
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Color(0xFFE5E7EB)),
                                  borderRadius: BorderRadius.circular(12),
                                  color: Color(0xFFF9FAFB),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        locationProvider.dropoffLocation?.name ?? 'Type a city name...',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: locationProvider.dropoffLocation != null ? Color(0xFF1F2937) : Color(0xFF9CA3AF),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.location_on, color: Color(0xFF059669), size: 18),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Distance and Price Display
                    Consumer<LocationProvider>(
                      builder: (context, locationProvider, _) {
                        if (locationProvider.pickupLocation != null && locationProvider.dropoffLocation != null) {
                          return Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Color(0xFFF0F9FF),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Color(0xFFBFDBFE)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Distance',
                                      style: TextStyle(fontSize: 11, color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '${locationProvider.distanceKm.toStringAsFixed(2)} km',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F67B1),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: Color(0xFFBFDBFE),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Price/km',
                                      style: TextStyle(fontSize: 11, color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '${PricingConstants.currencySymbol}${locationProvider.pricePerKm.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F67B1),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: Color(0xFFBFDBFE),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Base Price',
                                      style: TextStyle(fontSize: 11, color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '${PricingConstants.currencySymbol}${locationProvider.totalPrice.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF059669),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }
                        return SizedBox();
                      },
                    ),
                    SizedBox(height: 20),

                    // Date Range
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateFieldNew(
                            label: 'Pickup',
                            icon: Icons.calendar_today_outlined,
                            date: _pickupDate,
                            onTap: _selectPickupDate,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildDateFieldNew(
                            label: 'Dropoff',
                            icon: Icons.calendar_today_outlined,
                            date: _dropoffDate,
                            onTap: _selectDropoffDate,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),

                    // Search Button
                    CustomButton(
                      text: 'SEARCH CARS',
                      onPressed: _searchCars,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 48),

              // Featured Deals Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Featured Deals',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Popular cars right now',
                        style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Row(
                      children: [
                        Text('View all', style: TextStyle(color: Color(0xFF0F67B1), fontWeight: FontWeight.w600)),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward, color: Color(0xFF0F67B1), size: 18),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              Consumer<CarProvider>(
                builder: (context, carProvider, _) {
                  if (carProvider.isLoading) {
                    return LoadingWidget(message: 'Loading...');
                  }

                  if (carProvider.allCars.isEmpty) {
                    return SizedBox();
                  }

                  return ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: carProvider.allCars.take(3).length,
                    itemBuilder: (context, index) {
                      final car = carProvider.allCars[index];
                      return _buildFeaturedCarCard(car, context);
                    },
                  );
                },
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateFieldNew({
    required String label,
    required IconData icon,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Color(0xFF0F67B1), size: 16),
            SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
          ],
        ),
        SizedBox(height: 10),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(12),
              color: Color(0xFFF9FAFB),
            ),
            child: Text(
              date != null
                  ? '${date.day}/${date.month}/${date.year}'
                  : 'Select',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: date != null ? Color(0xFF1F2937) : Color(0xFF9CA3AF),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCarCard(Car car, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF000000).withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchResultsScreen(
                    location: _selectedLocation ?? 'New York',
                    pickupDate: _pickupDate ?? DateTime.now(),
                    dropoffDate: _dropoffDate ?? DateTime.now().add(Duration(days: 1)),
                  ),
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  // Car Image
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Color(0xFFF3F4F6),
                    ),
                    child: Icon(Icons.directions_car, size: 60, color: Color(0xFFD1D5DB)),
                  ),
                  SizedBox(width: 16),
                  // Car Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          car.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star_rounded, size: 14, color: Color(0xFFFCD34D)),
                            SizedBox(width: 4),
                            Text(
                              '${car.rating}',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1F2937)),
                            ),
                            SizedBox(width: 4),
                            Text(
                              '(${car.reviews})',
                              style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          '\$${car.dailyRate.toStringAsFixed(0)}/day',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F67B1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFFD1D5DB)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
