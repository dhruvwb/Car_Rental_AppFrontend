import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/index.dart';
import '../providers/index.dart';
import '../widgets/index.dart';
import '../utils/pricing_constants.dart';
import 'booking_confirmation_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final Car car;
  final DateTime pickupDate;
  final DateTime dropoffDate;
  final String pickupLocation;
  final String selectedInsurance;
  final List<String> selectedAddOns;
  final int numberOfDays;

  const CheckoutScreen({
    required this.car,
    required this.pickupDate,
    required this.dropoffDate,
    required this.pickupLocation,
    required this.selectedInsurance,
    required this.selectedAddOns,
    required this.numberOfDays,
  });

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _agreedToTerms = false;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    // Get insurance cost from PricingConstants
    final insuranceCost = PricingConstants.insuranceCosts[widget.selectedInsurance] ?? 0.0;

    // Get add-ons cost from PricingConstants (now using List<String>)
    final addOnsCost = widget.selectedAddOns.fold<double>(0.0, (sum, addonName) {
      final cost = PricingConstants.addOnsCosts[addonName] ?? 0.0;
      return sum + cost;
    });

    // Calculate total dynamically
    final subtotal = widget.car.dailyRate * widget.numberOfDays;
    final insuranceTotal = insuranceCost * widget.numberOfDays;
    final addOnsTotal = addOnsCost * widget.numberOfDays;
    final tax = (subtotal + insuranceTotal + addOnsTotal) * PricingConstants.taxPercentage;
    final total = subtotal + insuranceTotal + addOnsTotal + tax;

    return Scaffold(
      appBar: AppBar(
        title: Text('Review Booking'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Car Image with Info
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 240,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                  ),
                  child: widget.car.images.isNotEmpty
                      ? Image.network(
                          widget.car.images[0],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: Icon(
                                  Icons.directions_car,
                                  size: 100,
                                  color: Colors.grey[400],
                                ),
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Icon(
                            Icons.directions_car,
                            size: 100,
                            color: Colors.grey[400],
                          ),
                        ),
                ),
                // Back Button
                Positioned(
                  top: 16,
                  left: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.arrow_back, color: Colors.blue, size: 24),
                    ),
                  ),
                ),
              ],
            ),

            // Content
            Container(
              color: Color(0xFFFAFAFA),
              child: Column(
                children: [
                  // Car Header Card
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey[300]!,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.car.name,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
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
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.star, size: 16, color: Colors.white),
                                    SizedBox(width: 4),
                                    Text(
                                      '${widget.car.rating}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildSpecColumn(Icons.people, '${widget.car.seats}', 'Seats'),
                              _buildSpecColumn(Icons.luggage, '${widget.car.luggage}L', 'Luggage'),
                              _buildSpecColumn(Icons.settings, widget.car.transmission, 'Type'),
                              _buildSpecColumn(Icons.local_gas_station, widget.car.fuel, 'Fuel'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Rental Details
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey[300]!,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'RENTAL DETAILS',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 12),
                          _buildDetailRow('Location', widget.pickupLocation),
                          _buildDetailRow('Pickup', widget.pickupDate.toString().split(' ')[0]),
                          _buildDetailRow('Dropoff', widget.dropoffDate.toString().split(' ')[0]),
                          _buildDetailRow('Duration', '${widget.numberOfDays} day(s)'),
                        ],
                      ),
                    ),
                  ),

                  // Insurance & Add-ons
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey[300]!,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'INSURANCE & ADD-ONS',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 12),
                          _buildDetailRow('Insurance', widget.selectedInsurance, Colors.blue[100]!),
                          if (widget.selectedAddOns.isNotEmpty) ...[
                            SizedBox(height: 8),
                            Text(
                              'Add-ons:',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            SizedBox(height: 6),
                            ...widget.selectedAddOns.map((addon) {
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 3),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.check_circle, size: 16, color: Colors.green),
                                        SizedBox(width: 8),
                                        Text(addon, style: TextStyle(fontSize: 13)),
                                      ],
                                    ),
                                    Text(
                                      '+${PricingConstants.formatPrice(PricingConstants.addOnsCosts[addon] ?? 0)}/day',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ] else
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Icon(Icons.info, size: 16, color: Colors.grey[400]),
                                  SizedBox(width: 8),
                                  Text(
                                    'No add-ons selected',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Price Breakdown
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PRICE BREAKDOWN',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 12),
                          _buildPriceRow('Base Rate', '${PricingConstants.formatPrice(widget.car.dailyRate)}/day × ${widget.numberOfDays} days', subtotal),
                          Divider(height: 12),
                          _buildPriceRow('Insurance', '${PricingConstants.formatPrice(insuranceCost)}/day × ${widget.numberOfDays} days', insuranceTotal),
                          if (widget.selectedAddOns.isNotEmpty) ...[
                            Divider(height: 12),
                            _buildPriceRow('Add-ons', '${PricingConstants.formatPrice(addOnsCost)}/day × ${widget.numberOfDays} days', addOnsTotal),
                          ],
                          Divider(height: 12),
                          _buildPriceRow('Subtotal', '', subtotal + insuranceTotal + addOnsTotal, isSubtotal: true),
                          Divider(height: 12),
                          _buildPriceRow('Tax (18% GST)', '', tax, isTax: true),
                          Divider(height: 12),
                          _buildPriceRow('TOTAL', '', total, isTotal: true),
                        ],
                      ),
                    ),
                  ),

                  // Terms Checkbox
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey[300]!,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CheckboxListTile(
                        title: Text(
                          'I agree to the Terms & Conditions',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          'Free cancellation until 24 hours before pickup',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        value: _agreedToTerms,
                        onChanged: (value) {
                          setState(() {
                            _agreedToTerms = value ?? false;
                          });
                        },
                        activeColor: Colors.blue,
                      ),
                    ),
                  ),

                  // Confirm Button
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _agreedToTerms
                            ? () {
                                setState(() {
                                  _isProcessing = true;
                                });
                                Future.delayed(Duration(seconds: 2), () {
                                  if (mounted) {
                                    // Create booking object
                                    final booking = Booking(
                                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                                      userId: 'user_123', // Replace with actual user ID from provider
                                      carId: widget.car.id,
                                      pickupDate: widget.pickupDate,
                                      dropoffDate: widget.dropoffDate,
                                      pickupLocation: widget.pickupLocation,
                                      dropoffLocation: widget.pickupLocation,
                                      dailyRate: widget.car.dailyRate,
                                      numberOfDays: widget.numberOfDays,
                                      insuranceType: widget.selectedInsurance,
                                      insuranceCost: (PricingConstants.insuranceCosts[widget.selectedInsurance] ?? 0.0) * widget.numberOfDays,
                                      addOns: widget.selectedAddOns
                                          .map((addonName) => {
                                                'name': addonName,
                                                'cost': PricingConstants.addOnsCosts[addonName] ?? 0.0,
                                              })
                                          .toList(),
                                      subtotal: subtotal,
                                      tax: tax,
                                      totalCost: total,
                                      status: 'Confirmed',
                                      bookingDate: DateTime.now(),
                                    );

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BookingConfirmationScreen(
                                          booking: booking,
                                          car: widget.car,
                                        ),
                                      ),
                                    );
                                  }
                                });
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          disabledBackgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isProcessing
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Confirm Booking - ${PricingConstants.formatPrice(total)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecColumn(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue, size: 24),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, [Color? bgColor]) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[700], fontSize: 13),
          ),
          Container(
            padding: bgColor != null ? EdgeInsets.symmetric(horizontal: 12, vertical: 4) : null,
            decoration: bgColor != null
                ? BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                  )
                : null,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: bgColor != null ? Colors.blue[800] : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String description, double amount, {bool isSubtotal = false, bool isTax = false, bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
                  fontSize: isTotal ? 16 : 13,
                  color: isTotal ? Colors.blue[800] : Colors.grey[800],
                ),
              ),
              if (description.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Text(
                    description,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ),
            ],
          ),
          Text(
            PricingConstants.formatPrice(amount),
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              fontSize: isTotal ? 16 : 13,
              color: isTotal ? Colors.blue[800] : (isTax ? Colors.orange[700] : Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }
}
