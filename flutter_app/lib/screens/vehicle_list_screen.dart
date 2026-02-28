import 'package:flutter/material.dart';

import '../models/vehicle.dart';
import '../services/vehicle_api_service.dart';
import 'vehicle_detail_screen.dart';

class VehicleListScreen extends StatefulWidget {
  const VehicleListScreen({super.key, required this.apiService});

  final VehicleApiService apiService;

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  late Future<List<Vehicle>> _vehiclesFuture;

  @override
  void initState() {
    super.initState();
    _vehiclesFuture = widget.apiService.fetchVehicles();
  }

  Future<void> _reloadVehicles() async {
    setState(() {
      _vehiclesFuture = widget.apiService.fetchVehicles();
    });
  }

  Color _statusColor(String status) {
    return status == 'active' ? Colors.green : Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vehicles')),
      body: FutureBuilder<List<Vehicle>>(
        future: _vehiclesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final vehicles = snapshot.data ?? [];
          if (vehicles.isEmpty) {
            return const Center(child: Text('No vehicles found'));
          }

          return RefreshIndicator(
            onRefresh: _reloadVehicles,
            child: ListView.builder(
              itemCount: vehicles.length,
              itemBuilder: (context, index) {
                final vehicle = vehicles[index];
                return ListTile(
                  title: Text(vehicle.name),
                  subtitle: Text('ID: ${vehicle.id}'),
                  trailing: Chip(
                    label: Text(vehicle.status),
                    backgroundColor: _statusColor(vehicle.status).withOpacity(0.2),
                    labelStyle: TextStyle(color: _statusColor(vehicle.status)),
                  ),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => VehicleDetailScreen(
                          apiService: widget.apiService,
                          vehicle: vehicle,
                        ),
                      ),
                    );
                    await _reloadVehicles();
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
