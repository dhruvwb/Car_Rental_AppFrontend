import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/admin/providers/admin_provider.dart';
import 'package:myapp/admin/screens/admin_cars_screen.dart';
import 'package:myapp/admin/screens/admin_bookings_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        context.read<AdminProvider>().loadDashboardData();
      }
    });
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AdminProvider>().adminLogout();
              Navigator.pushReplacementNamed(context, '/admin_login');
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFB),
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Consumer<AdminProvider>(
                builder: (context, adminProvider, _) => Text(
                  adminProvider.adminName ?? 'Admin',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, _) {
          if (adminProvider.isLoading && adminProvider.dashboardStats.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F67B1), Color(0xFF17A2B8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${adminProvider.adminName}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Manage your car rental business efficiently',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Statistics Section
                  const Text(
                    'Dashboard Statistics',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Stats Cards
                  GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 1.2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: [
                      _buildStatCard(
                        title: 'Total Cars',
                        value: '${adminProvider.dashboardStats['totalCars'] ?? 0}',
                        icon: Icons.directions_car,
                        color: const Color(0xFF0F67B1),
                      ),
                      _buildStatCard(
                        title: 'Available',
                        value: '${adminProvider.dashboardStats['availableCars'] ?? 0}',
                        icon: Icons.check_circle,
                        color: Colors.green,
                      ),
                      _buildStatCard(
                        title: 'Pending Bookings',
                        value: '${adminProvider.dashboardStats['pendingBookings'] ?? 0}',
                        icon: Icons.pending_actions,
                        color: Colors.orange,
                      ),
                      _buildStatCard(
                        title: 'Total Bookings',
                        value: '${adminProvider.dashboardStats['totalBookings'] ?? 0}',
                        icon: Icons.calendar_today,
                        color: const Color(0xFF17A2B8),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Analytics Section Title
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Quick Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          label: 'Manage Cars',
                          icon: Icons.directions_car,
                          onPressed: () {
                            setState(() {
                              _selectedIndex = 0;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          label: 'Bookings',
                          icon: Icons.calendar_today,
                          onPressed: () {
                            setState(() {
                              _selectedIndex = 1;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          label: 'Add New Car',
                          icon: Icons.add,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => const AddCarDialog(),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          label: 'Refresh',
                          icon: Icons.refresh,
                          onPressed: () {
                            _loadDashboardData();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Content Section Based on Selection
                  if (_selectedIndex == 0) const AdminCarsScreen(),
                  if (_selectedIndex == 1) const AdminBookingsScreen(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0F67B1),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class AddCarDialog extends StatefulWidget {
  const AddCarDialog({Key? key}) : super(key: key);

  @override
  State<AddCarDialog> createState() => _AddCarDialogState();
}

class _AddCarDialogState extends State<AddCarDialog> {
  late TextEditingController nameController;
  late TextEditingController modelController;
  late TextEditingController yearController;
  late TextEditingController typeController;
  late TextEditingController rateController;
  late TextEditingController registrationController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    modelController = TextEditingController();
    yearController = TextEditingController();
    typeController = TextEditingController();
    rateController = TextEditingController();
    registrationController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    modelController.dispose();
    yearController.dispose();
    typeController.dispose();
    rateController.dispose();
    registrationController.dispose();
    super.dispose();
  }

  void _addCar() async {
    if (nameController.text.isEmpty || modelController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final adminProvider = context.read<AdminProvider>();
    final success = await adminProvider.addCar(
      name: nameController.text,
      model: modelController.text,
      year: int.tryParse(yearController.text) ?? DateTime.now().year,
      type: typeController.text.isEmpty ? 'Sedan' : typeController.text,
      dailyRate: double.tryParse(rateController.text) ?? 0.0,
      transmission: 'Automatic',
      fuel: 'Petrol',
      seats: 5,
      luggage: 300,
      features: ['Feature 1', 'Feature 2'],
      images: [],
      registrationNumber: registrationController.text,
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Car added successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Car'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Car Name',
                hintText: 'e.g., Toyota Fortuner',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: modelController,
              decoration: const InputDecoration(
                labelText: 'Model',
                hintText: 'e.g., 2023',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: yearController,
              decoration: const InputDecoration(
                labelText: 'Year',
                hintText: '2023',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: typeController,
              decoration: const InputDecoration(
                labelText: 'Type',
                hintText: 'e.g., SUV',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: rateController,
              decoration: const InputDecoration(
                labelText: 'Daily Rate',
                hintText: '5000',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: registrationController,
              decoration: const InputDecoration(
                labelText: 'Registration Number',
                hintText: 'e.g., DL01AB1234',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addCar,
          child: const Text('Add Car'),
        ),
      ],
    );
  }
}
