// config/api_config.dart
class ApiConfig {
  // Base API URL for the backend services
  static const String baseApiUrl = 'https://YOUR_API_ENDPOINT_HERE/api';
  
  // Device management endpoints
  static const String registerDeviceEndpoint = '$baseApiUrl/register_device';
  static const String userDevicesEndpoint = '$baseApiUrl/devices';
  static const String deviceEndpoint = '$baseApiUrl/device';
}
