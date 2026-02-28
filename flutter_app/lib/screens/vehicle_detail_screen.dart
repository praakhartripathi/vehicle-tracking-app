import 'package:flutter/material.dart';

import '../models/vehicle.dart';
import '../services/vehicle_api_service.dart';

class VehicleDetailScreen extends StatefulWidget {
  const VehicleDetailScreen({
    super.key,
    required this.vehicle,
    required this.apiService,
  });

  final Vehicle vehicle;
  final VehicleApiService apiService;

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  late Vehicle _vehicle;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _vehicle = widget.vehicle;
  }

  Future<void> _toggleStatus() async {
    final nextStatus = _vehicle.status == 'active' ? 'inactive' : 'active';

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedVehicle = await widget.apiService.updateVehicleStatus(
        id: _vehicle.id,
        status: nextStatus,
      );

      if (!mounted) return;
      setState(() {
        _vehicle = updatedVehicle;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vehicle Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${_vehicle.name}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('ID: ${_vehicle.id}'),
            const SizedBox(height: 8),
            Text('Status: ${_vehicle.status}'),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isSaving ? null : _toggleStatus,
              child: Text(_isSaving
                  ? 'Saving...'
                  : _vehicle.status == 'active'
                      ? 'Mark Inactive'
                      : 'Mark Active'),
            ),
          ],
        ),
      ),
    );
  }
}
