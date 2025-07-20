import 'package:flutter/foundation.dart';
import '../models/device_location.dart';

/// A mock service that provides test data for the location features
/// Used when the backend API is not available or returns errors
class MockLocationService {
  // Singleton instance
  static final MockLocationService _instance = MockLocationService._internal();
  factory MockLocationService() => _instance;
  MockLocationService._internal();
  
  // In-memory storage for device locations
  final Map<String, DeviceLocation> _deviceLocations = {};
  
  // Initialize with some test data
  void initialize() {
    // Add some test devices
    updateDeviceLocation(
      deviceId: 'test-device-001',
      latitude: 37.7749,
      longitude: -122.4194,
      locationName: 'San Francisco Device',
      description: 'A test device in San Francisco'
    );
    
    updateDeviceLocation(
      deviceId: 'test-device-002',
      latitude: 40.7128,
      longitude: -74.0060,
      locationName: 'New York Device',
      description: 'A test device in New York'
    );
    
    updateDeviceLocation(
      deviceId: 'test-device-003',
      latitude: 51.5074,
      longitude: -0.1278,
      locationName: 'London Device',
      description: 'A test device in London'
    );
    
    debugPrint('MockLocationService initialized with ${_deviceLocations.length} test devices');
  }
  
  // Update or create a device location
  DeviceLocation updateDeviceLocation({
    required String deviceId,
    required double latitude,
    required double longitude,
    String? locationName,
    String? description,
  }) {
    final now = DateTime.now().toIso8601String();
    
    final location = DeviceLocation(
      deviceId: deviceId,
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
      description: description,
      lastUpdated: now,
    );
    
    _deviceLocations[deviceId] = location;
    return location;
  }
  
  // Get a device location by ID
  DeviceLocation getDeviceLocation(String deviceId) {
    if (!_deviceLocations.containsKey(deviceId)) {
      throw Exception('Device not found');
    }
    return _deviceLocations[deviceId]!;
  }
  
  // Get all device locations
  List<DeviceLocation> getUserDevicesLocations() {
    return _deviceLocations.values.toList();
  }
  
  // Get Google Maps API key
  String getMapsApiKey() {
    return 'AIzaSyBmUCtQ_DlYKSU_BV7JdiyoOu1jvDj3Cb0';
  }
}
