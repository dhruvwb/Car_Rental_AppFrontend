import 'package:flutter/material.dart';
import '../models/index.dart';
import '../widgets/index.dart';
import 'home_screen.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final Booking booking;
  final Car car;

  const BookingConfirmationScreen({
    required this.booking,
    required this.car,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Success Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[400]!, Colors.green[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.check_circle, size: 80, color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'BOOKING CONFIRMED!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Booking ID: ${booking.id}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontFamily: 'Courier',
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Car Details Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.directions_car, color: Colors.blue, size: 40),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      car.name,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Reg: ${booking.carRegistration}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Pickup & Dropoff
                  _buildLocationCard(
                    icon: Icons.location_on,
                    title: 'Pickup',
                    location: booking.pickupLocation,
                    date: booking.pickupDate,
                  ),
                  SizedBox(height: 12),
                  _buildLocationCard(
                    icon: Icons.location_off,
                    title: 'Dropoff',
                    location: booking.dropoffLocation,
                    date: booking.dropoffDate,
                  ),
                  SizedBox(height: 20),

                  // Booking Details
                  Text(
                    'BOOKING DETAILS',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 12),
                  _buildDetailRow('Duration', '${booking.numberOfDays} days'),
                  _buildDetailRow('Insurance', booking.insuranceType),
                  _buildDetailRow('Total Cost', '\$${booking.totalCost.toStringAsFixed(2)}'),
                  _buildDetailRow('Status', booking.status,
                      color: Colors.green),
                  SizedBox(height: 20),

                  // Pricing Summary
                  PriceBreakdownWidget(
                    dailyRate: booking.dailyRate,
                    numberOfDays: booking.numberOfDays,
                    insuranceCost: booking.insuranceCost,
                    addOnsCost:
                        booking.addOns.fold(0.0, (sum, addon) => sum + (addon['cost'] ?? 0.0)),
                  ),
                  SizedBox(height: 20),

                  // Important Info
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      border: Border.all(color: Colors.blue[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info, color: Colors.blue[700], size: 20),
                            SizedBox(width: 10),
                            Text(
                              'Important Information',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        _buildInfoPoint('Arrive 15 minutes before pickup time'),
                        _buildInfoPoint('Bring valid driving license and ID'),
                        _buildInfoPoint('Full tank provided, return with full tank'),
                        _buildInfoPoint('Free cancellation until 24 hours before pickup'),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Contact Support
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Need Help?',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.phone, color: Colors.blue, size: 18),
                            SizedBox(width: 8),
                            Text('+1-800-CAR-RENT', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                        SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.email, color: Colors.blue, size: 18),
                            SizedBox(width: 8),
                            Text('support@carrentalapp.com', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Action Buttons
                  CustomButton(
                    text: 'DOWNLOAD ITINERARY',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Itinerary downloaded')),
                      );
                    },
                    backgroundColor: Colors.grey[700],
                  ),
                  SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                        (route) => false,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: BorderSide(color: Colors.blue, width: 2),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.home, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'BACK TO HOME',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard({
    required IconData icon,
    required String title,
    required String location,
    required DateTime date,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                Text(
                  location,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700])),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPoint(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(Icons.check, color: Colors.green, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}
