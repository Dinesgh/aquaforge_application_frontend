// models/sensor_data.dart
class SensorData {
  final DateTime timestamp;
  final double pHValue;
  final double dissolvedOxygen;
  final double waterTemperature;
  final double tdsWater;
  final double airTemperature;
  final double airHumidity;
  final String deviceId;

  SensorData({
    required this.timestamp,
    required this.pHValue,
    required this.dissolvedOxygen,
    required this.waterTemperature,
    required this.tdsWater,
    required this.airTemperature,
    required this.airHumidity,
    required this.deviceId,
  });

  // Factory constructor to create a SensorData object from a JSON map
  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      // Assuming timestamp is a string in ISO 8601 format
      timestamp: DateTime.parse(json['timestamp']),
      pHValue: json['pHValue']?.toDouble() ?? 0.0,
      dissolvedOxygen: json['dissolvedOxygen']?.toDouble() ?? 0.0,
      waterTemperature: json['waterTemperature']?.toDouble() ?? 0.0,
      tdsWater: json['tdsWater']?.toDouble() ?? 0.0,
      airTemperature: json['airTemperature']?.toDouble() ?? 0.0,
      airHumidity: json['airHumidity']?.toDouble() ?? 0.0,
      deviceId: json['deviceId'] ?? '',
    );
  }

  // Method to convert SensorData object to a JSON map (useful for sending data)
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'pHValue': pHValue,
      'dissolvedOxygen': dissolvedOxygen,
      'waterTemperature': waterTemperature,
      'tdsWater': tdsWater,
      'airTemperature': airTemperature,
      'airHumidity': airHumidity,
      'deviceId': deviceId,
    };
  }

  // Factory method for mock/default data
  factory SensorData.mock() {
    return SensorData(
      timestamp: DateTime.now(),
      pHValue: 7.5,
      dissolvedOxygen: 6.5,
      waterTemperature: 25.0,
      tdsWater: 200.0,
      airTemperature: 28.0,
      airHumidity: 75.0,
      deviceId: 'Device-001',
    );
  }
}