import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/index.dart';
import '../providers/index.dart';
import '../../widgets/index.dart';
import '../../utils/pricing_constants.dart';
import 'checkout_screen.dart';

class CarDetailsScreen extends StatefulWidget {
  final Car car;
  final DateTime pickupDate;
  final DateTime dropoffDate;
  final String pickupLocation;

  const CarDetailsScreen({
    required this.car,
    required this.pickupDate,
    required this.dropoffDate,
    required this.pickupLocation,
  });

  @override
  _CarDetailsScreenState createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  String _selectedInsurance = 'Basic';
  List<String> _selectedAddOns = [];

  // Use insurance costs from PricingConstants
  Map<String, double> get _insuranceOptions => PricingConstants.insuranceCosts;

  // Use add-ons costs from PricingConstants
  List<MapEntry<String, double>> get _addOns => 
      PricingConstants.addOnsCosts.entries.toList();

  int get _numberOfDays => widget.dropoffDate.difference(widget.pickupDate).inDays + 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.car.name),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Car Image
            Container(
              width: double.infinity,
              height: 250,
              color: Colors.grey[300],
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.directions_car,
                      size: 150,
                      color: Colors.grey[700],
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.arrow_back),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Car Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.car.name,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.car.model,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.car.type,
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),

                  // Rating
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 18),
                      SizedBox(width: 4),
                      Text(
                        '${widget.car.rating}',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      SizedBox(width: 4),
                      Text(
                        '(${widget.car.reviews} reviews)',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      Spacer(),
                      Text(
                        '✓ 100% Verified',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Specifications
                  Text(
                    'SPECIFICATIONS',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 10),
                  _buildSpecRow('Model Year', '${widget.car.year} (${DateTime.now().year - widget.car.year} years old)'),
                  _buildSpecRow('Transmission', widget.car.transmission),
                  _buildSpecRow('Fuel Type', widget.car.fuel),
                  _buildSpecRow('Seats', '${widget.car.seats}'),
                  _buildSpecRow('Luggage', '${widget.car.luggage}L'),
                  SizedBox(height: 16),

                  // Features
                  Text(
                    'FEATURES',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.car.features.map((feature) {
                      return Chip(
                        avatar: Icon(Icons.check_circle, size: 18, color: Colors.green),
                        label: Text(feature),
                        backgroundColor: Colors.green[50],
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),

                  // Insurance Selection
                  Text(
                    'SELECT INSURANCE',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 10),
                  ..._insuranceOptions.entries.map((entry) {
                    return RadioListTile<String>(
                      title: Text(entry.key),
                      subtitle: entry.value > 0
                          ? Text(
                              '+${PricingConstants.formatPrice(entry.value)}/day'
                            )
                          : null,
                      value: entry.key,
                      groupValue: _selectedInsurance,
                      onChanged: (value) {
                        setState(() {
                          _selectedInsurance = value!;
                        });
                      },
                    );
                  }).toList(),
                  SizedBox(height: 20),

                  // Add-ons
                  Text(
                    'ADD-ONS (OPTIONAL)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 10),
                  ..._addOns.map((addon) {
                    final isSelected = _selectedAddOns.contains(addon.key);
                    return CheckboxListTile(
                      title: Text(addon.key),
                      subtitle: Text(
                        '+${PricingConstants.formatPrice(addon.value)}/day'
                      ),
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value!) {
                            _selectedAddOns.add(addon.key);
                          } else {
                            _selectedAddOns.remove(addon.key);
                          }
                        });
                      },
                    );
                  }).toList(),
                  SizedBox(height: 20),

                  // Pricing Breakdown
                  PriceBreakdownWidget(
                    dailyRate: widget.car.dailyRate,
                    numberOfDays: _numberOfDays,
                    insuranceCost: (_insuranceOptions[_selectedInsurance] ?? 0.0) * _numberOfDays,
                    addOnsCost: _selectedAddOns.fold(
                      0.0,
                      (sum, addonName) => sum + (PricingConstants.addOnsCosts[addonName] ?? 0.0)
                    ) * _numberOfDays,
                  ),
                  SizedBox(height: 20),

                  // Proceed Button
                  CustomButton(
                    text: 'PROCEED TO CHECKOUT',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckoutScreen(
                            car: widget.car,
                            pickupDate: widget.pickupDate,
                            dropoffDate: widget.dropoffDate,
                            pickupLocation: widget.pickupLocation,
                            selectedInsurance: _selectedInsurance,
                            selectedAddOns: _selectedAddOns,
                            numberOfDays: _numberOfDays,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      border: Border.all(color: Colors.green[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.green[700], size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Free cancellation until 24 hours before pickup',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700])),
          Text(value, style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
