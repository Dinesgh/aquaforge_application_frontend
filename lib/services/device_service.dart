import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:amplify_flutter/amplify_flutter.dart';
import 'auth_service.dart';

class DeviceService {
  final String apiUrl;
  final AuthService authService;

  DeviceService({
    required this.apiUrl,
    required this.authService,
  });

  /// Get authentication token from Cognito (delegate to AuthService)
  Future<String?> _getAuthToken() async {
    try {
      // For API authorization, we'll use getCurrentUser to get a valid session token
      final authSession = await Amplify.Auth.fetchAuthSession();
      if (authSession.isSignedIn) {
        // In a real implementation, you would extract the token from the authSession
        // For now, we use a placeholder since we're in development mode
        return "valid-token-from-auth-session"; // Simplified version
      }
      return null;
    } catch (e) {
      debugPrint('Error getting auth token: $e');
      return null;
    }
  }
  
  /// Get current user ID (Cognito sub)
  Future<String?> _getCurrentUserId() async {
    return authService.getCurrentUserId();
  }
  
  /// Get current user email
  Future<String?> _getCurrentUserEmail() async {
    return authService.getCurrentUserEmail();
  }

  /// Register a new device for the current user
  Future<Map<String, dynamic>> registerDevice({
    required String deviceId,
    String? deviceName,
    String? deviceType,
    String? location,
    Map<String, dynamic>? settings,
  }) async {
    final token = await _getAuthToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }
    
    // Get user ID and email
    final userId = await _getCurrentUserId();
    final userEmail = await _getCurrentUserEmail();

    final url = Uri.parse('$apiUrl/register_device');
    
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'device_id': deviceId,
        if (deviceName != null) 'device_name': deviceName,
        if (deviceType != null) 'device_type': deviceType,
        if (location != null) 'location': location,
        if (settings != null) 'settings': settings,
        if (userId != null) 'user_id': userId,
        if (userEmail != null) 'user_email': userEmail,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to register device');
    }
  }

  /// Get all devices for the current user
  Future<List<dynamic>> getUserDevices() async {
    final token = await _getAuthToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }

    final url = Uri.parse('$apiUrl/devices');
    
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['devices'] ?? [];
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to get devices');
    }
  }

  /// Update device details
  Future<Map<String, dynamic>> updateDevice({
    required String deviceId,
    String? deviceName,
    String? status,
    String? location,
    Map<String, dynamic>? settings,
  }) async {
    final token = await _getAuthToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }

    final url = Uri.parse('$apiUrl/device');
    
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'device_id': deviceId,
        if (deviceName != null) 'device_name': deviceName,
        if (status != null) 'status': status,
        if (location != null) 'location': location,
        if (settings != null) 'settings': settings,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to update device');
    }
  }

  /// Delete a device association
  Future<void> deleteDevice(String deviceId) async {
    final token = await _getAuthToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }

    final url = Uri.parse('$apiUrl/device');
    
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'device_id': deviceId,
      }),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to delete device');
    }
  }
}
