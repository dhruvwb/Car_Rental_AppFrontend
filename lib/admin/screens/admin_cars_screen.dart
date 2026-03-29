import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/admin/providers/admin_provider.dart';
import 'package:myapp/models/car.dart';

class AdminCarsScreen extends StatefulWidget {
  const AdminCarsScreen({Key? key}) : super(key: key);

  @override
  State<AdminCarsScreen> createState() => _AdminCarsScreenState();
}

class _AdminCarsScreenState extends State<AdminCarsScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        context.read<AdminProvider>().loadCars();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, _) {
        if (adminProvider.cars.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.directions_car, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No cars found',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fleet Management',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: adminProvider.cars.length,
              itemBuilder: (context, index) {
                final car = adminProvider.cars[index];
                return _buildCarCard(car, context, adminProvider);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCarCard(Car car, BuildContext context, AdminProvider adminProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      car.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${car.model} • ${car.year}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: car.isAvailable ? Colors.green[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  car.isAvailable ? 'Available' : 'Unavailable',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: car.isAvailable ? Colors.green[700] : Colors.red[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCarDetail('₹${car.dailyRate.toStringAsFixed(0)}/day', Icons.currency_rupee),
              _buildCarDetail('${car.seats} seats', Icons.person),
              _buildCarDetail('${car.luggage}L', Icons.luggage),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => EditCarDialog(car: car),
                    );
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F67B1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Car'),
                        content: Text('Are you sure you want to delete ${car.name}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              adminProvider.deleteCar(car.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Car deleted successfully')),
                              );
                            },
                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCarDetail(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF0F67B1)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: Color(0xFF1F2937)),
        ),
      ],
    );
  }
}

class EditCarDialog extends StatefulWidget {
  final Car car;

  const EditCarDialog({Key? key, required this.car}) : super(key: key);

  @override
  State<EditCarDialog> createState() => _EditCarDialogState();
}

class _EditCarDialogState extends State<EditCarDialog> {
  late TextEditingController nameController;
  late TextEditingController modelController;
  late TextEditingController yearController;
  late TextEditingController typeController;
  late TextEditingController rateController;
  late TextEditingController registrationController;
  late bool isAvailable;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.car.name);
    modelController = TextEditingController(text: widget.car.model);
    yearController = TextEditingController(text: widget.car.year.toString());
    typeController = TextEditingController(text: widget.car.type);
    rateController = TextEditingController(text: widget.car.dailyRate.toString());
    registrationController = TextEditingController(text: widget.car.registrationNumber);
    isAvailable = widget.car.isAvailable;
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

  void _updateCar() async {
    final adminProvider = context.read<AdminProvider>();
    final success = await adminProvider.updateCar(
      carId: widget.car.id,
      name: nameController.text,
      model: modelController.text,
      year: int.tryParse(yearController.text) ?? widget.car.year,
      type: typeController.text,
      dailyRate: double.tryParse(rateController.text) ?? widget.car.dailyRate,
      transmission: widget.car.transmission,
      fuel: widget.car.fuel,
      seats: widget.car.seats,
      luggage: widget.car.luggage,
      features: widget.car.features,
      images: widget.car.images,
      registrationNumber: registrationController.text,
      available: isAvailable,
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Car updated successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Car'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Car Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: modelController,
              decoration: const InputDecoration(labelText: 'Model'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: yearController,
              decoration: const InputDecoration(labelText: 'Year'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: typeController,
              decoration: const InputDecoration(labelText: 'Type'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: rateController,
              decoration: const InputDecoration(labelText: 'Daily Rate'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: registrationController,
              decoration: const InputDecoration(labelText: 'Registration Number'),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              value: isAvailable,
              onChanged: (value) {
                setState(() {
                  isAvailable = value ?? true;
                });
              },
              title: const Text('Available for booking'),
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
          onPressed: _updateCar,
          child: const Text('Update'),
        ),
      ],
    );
  }
}
