import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/sensor_data.dart';

class PredictionService {
  final String apiUrl;
  PredictionService({required this.apiUrl});

  Future<String> getPrediction(SensorData data) async {
    final response = await http.post(
      Uri.parse('$apiUrl/predict'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data.toJson()),
    );
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      return result['prediction']?.toString() ?? 'No prediction';
    } else {
      throw Exception('Failed to get prediction: ${response.statusCode}');
    }
  }
}
