// services/data_service.dart
import 'dart:math';
import '../models/sensor_data.dart';

class DataService {
  // This method would fetch real data from your AWS API Gateway
  Future<List<SensorData>> fetchSensorData() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      // --- Start of Mock Data Generation (Replace this with actual HTTP call) ---
      final List<SensorData> mockData = [];
      final Random random = Random();
      DateTime now = DateTime.now();

      for (int i = 0; i < 30; i++) { // Generate data for the last 30 time points
        mockData.add(
          SensorData(
            timestamp: now.subtract(Duration(minutes: (29 - i) * 5)), // Data every 5 minutes
            pHValue: 6.5 + random.nextDouble() * 1.5, // pH between 6.5 and 8.0
            dissolvedOxygen: 5.0 + random.nextDouble() * 3.0, // DO between 5.0 and 8.0 mg/L
            waterTemperature: 20.0 + random.nextDouble() * 8.0, // Water Temp between 20 and 28 C
            tdsWater: 150 + random.nextDouble() * 100, // TDS between 150 and 250 ppm
            airTemperature: 25.0 + random.nextDouble() * 10.0, // Air Temp between 25 and 35 C
            airHumidity: 60.0 + random.nextDouble() * 30.0, // Air Humidity between 60 and 90 %
            deviceId: 'Device-001', // Mock device ID
          ),
        );
      }
      // --- End of Mock Data Generation ---

      return mockData;
    } catch (e) {
      print('Error fetching sensor data: $e');
      // In a real app, you might want to throw a custom exception or return an empty list
      return [];
    }
  }

  // This method would send data to your AWS API Gateway (e.g., for control signals if needed)
  Future<bool> sendControlSignal(Map<String, dynamic> data) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // --- Example of a real HTTP POST call (uncomment and modify for actual use) ---
      /*
      final response = await http.post(
        Uri.parse('$_apiUrl/control'), // Example endpoint for control
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to send control signal: ${response.statusCode}');
        return false;
      }
      */
      print('Mock: Sending control signal: $data');
      return true; // Mock success
    } catch (e) {
      print('Error sending control signal: $e');
      return false;
    }
  }
}
