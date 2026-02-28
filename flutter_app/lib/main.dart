import 'package:flutter/material.dart';

import 'screens/vehicle_list_screen.dart';
import 'services/vehicle_api_service.dart';

void main() {
  runApp(const VehicleTrackingApp());
}

class VehicleTrackingApp extends StatelessWidget {
  const VehicleTrackingApp({super.key});

  @override
  Widget build(BuildContext context) {
    const apiBaseUrl = String.fromEnvironment(
      'API_BASE_URL',
      // Android emulator uses 10.0.2.2 for localhost; update for iOS/device.
      defaultValue: 'http://10.0.2.2:3000',
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vehicle Tracking',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: VehicleListScreen(
        apiService: VehicleApiService(baseUrl: apiBaseUrl),
      ),
    );
  }
}
