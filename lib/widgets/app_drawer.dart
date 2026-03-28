import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/index.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Drawer Header with User Info
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                final user = authProvider.currentUser;
                return Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0F67B1), Color(0xFF1e88e5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.white,
                        child: Text(
                          user?.name.isNotEmpty == true
                              ? user!.name[0].toUpperCase()
                              : 'U',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F67B1),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        user?.name ?? 'User',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        user?.email ?? 'user@example.com',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: 20),

            // Route Information  
            Consumer<LocationProvider>(
              builder: (context, locationProvider, _) {
                if (locationProvider.pickupLocation != null ||
                    locationProvider.dropoffLocation != null) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Route Details',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                        SizedBox(height: 12),
                        if (locationProvider.pickupLocation != null) ...[
                          Row(
                            children: [
                              Icon(Icons.location_on, color: Color(0xFF0F67B1), size: 16),
                              SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'From',
                                      style: TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
                                    ),
                                    Text(
                                      locationProvider.pickupLocation!.name,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                        ],
                        if (locationProvider.dropoffLocation != null) ...[
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined, color: Color(0xFF059669), size: 16),
                              SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'To',
                                      style: TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
                                    ),
                                    Text(
                                      locationProvider.dropoffLocation!.name,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Divider(color: Colors.grey[300]),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Distance',
                                    style: TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
                                  ),
                                  Text(
                                    '${locationProvider.distanceKm.toStringAsFixed(2)} km',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F67B1),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Est. Price',
                                    style: TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
                                  ),
                                  Text(
                                    '\$${locationProvider.totalPrice.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF059669),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                }
                return SizedBox();
              },
            ),
            SizedBox(height: 20),

            // Menu Items
            _buildDrawerItem(
              context,
              icon: Icons.home_outlined,
              label: 'Home',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/home');
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.directions_car_outlined,
              label: 'My Bookings',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('My Bookings feature coming soon')),
                );
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.favorite_outline,
              label: 'Saved Locations',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Saved Locations feature coming soon')),
                );
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.payment_outlined,
              label: 'Payment Methods',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Payment Methods feature coming soon')),
                );
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.settings_outlined,
              label: 'Settings',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Settings feature coming soon')),
                );
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.help_outline,
              label: 'Help & Support',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Help & Support feature coming soon')),
                );
              },
            ),
            SizedBox(height: 20),
            Divider(color: Colors.grey[300]),
            SizedBox(height: 20),
            _buildDrawerItem(
              context,
              icon: Icons.logout_outlined,
              label: 'Logout',
              onTap: () => _handleLogout(context),
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('Logout', style: TextStyle(color: Colors.red)),
              onPressed: () {
                final authProvider = context.read<AuthProvider>();
                authProvider.logout();
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close drawer
                Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : Color(0xFF6B7280),
        size: 20,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isDestructive ? Colors.red : Color(0xFF111827),
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      onTap: onTap,
    );
  }
}
