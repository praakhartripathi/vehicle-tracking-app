import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/vehicle.dart';

class VehicleApiService {
  VehicleApiService({required this.baseUrl});

  final String baseUrl;

  Future<List<Vehicle>> fetchVehicles() async {
    final response = await http.get(Uri.parse('$baseUrl/api/vehicles'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load vehicles');
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((dynamic item) => Vehicle.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Vehicle> updateVehicleStatus({
    required String id,
    required String status,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/api/vehicles/$id/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update status');
    }

    return Vehicle.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
