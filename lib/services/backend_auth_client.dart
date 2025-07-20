import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Backend Authentication API client
/// This class handles all authentication-related operations by making calls
/// to our Python backend API instead of directly interacting with AWS Cognito
class BackendAuthClient {
  static final BackendAuthClient _instance = BackendAuthClient._internal();
  factory BackendAuthClient() => _instance;
  BackendAuthClient._internal();

  final String baseUrl = 'http://localhost:8000'; // Updated to match current development server port
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Helper function to create a standard headers map
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // Helper to add auth token to headers if available
  Future<Map<String, String>> _getAuthHeaders() async {
    final headers = _getHeaders();
    final accessToken = await _secureStorage.read(key: 'access_token');
    
    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }
    
    return headers;
  }

  // Save auth tokens to secure storage
  Future<void> _saveTokens(Map<String, dynamic> tokens) async {
    await _secureStorage.write(key: 'access_token', value: tokens['access_token']);
    await _secureStorage.write(key: 'id_token', value: tokens['id_token']);
    await _secureStorage.write(key: 'refresh_token', value: tokens['refresh_token']);
    
    // Store token expiration time
    final expiresIn = tokens['expires_in'];
    if (expiresIn != null) {
      final expirationTime = DateTime.now().add(Duration(seconds: expiresIn)).toIso8601String();
      await _secureStorage.write(key: 'token_expiry', value: expirationTime);
    }
  }

  // Clear all stored tokens
  Future<void> _clearTokens() async {
    await _secureStorage.delete(key: 'access_token');
    await _secureStorage.delete(key: 'id_token');
    await _secureStorage.delete(key: 'refresh_token');
    await _secureStorage.delete(key: 'token_expiry');
    await _secureStorage.delete(key: 'user_data');
  }

  // Check if the user is authenticated and tokens are valid
  Future<bool> isAuthenticated() async {
    try {
      final accessToken = await _secureStorage.read(key: 'access_token');
      final tokenExpiry = await _secureStorage.read(key: 'token_expiry');
      
      if (accessToken == null || tokenExpiry == null) {
        return false;
      }
      
      // Check if token has expired
      final expiryTime = DateTime.parse(tokenExpiry);
      final now = DateTime.now();
      
      if (now.isAfter(expiryTime)) {
        // Token has expired, try to refresh it
        final refreshToken = await _secureStorage.read(key: 'refresh_token');
        if (refreshToken != null) {
          try {
            await refreshAuthToken(refreshToken);
            return true;
          } catch (e) {
            debugPrint('Failed to refresh token: $e');
            return false;
          }
        }
        return false;
      }
      
      return true;
    } catch (e) {
      debugPrint('Error checking authentication: $e');
      return false;
    }
  }

  // Register a new user
  Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    required String email,
    String? name,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: _getHeaders(),
        body: jsonEncode({
          'username': username,
          'password': password,
          'email': email,
          if (name != null) 'name': name,
        }),
      );
      
      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Registration failed');
      }
      
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('Error during registration: $e');
      rethrow;
    }
  }

  // Confirm user registration with verification code
  Future<Map<String, dynamic>> confirmRegistration({
    required String username,
    required String confirmationCode,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/confirm'),
        headers: _getHeaders(),
        body: jsonEncode({
          'username': username,
          'confirmation_code': confirmationCode,
        }),
      );
      
      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Confirmation failed');
      }
      
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('Error confirming registration: $e');
      rethrow;
    }
  }

  // Resend confirmation code
  Future<Map<String, dynamic>> resendConfirmationCode({
    required String username,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/resend-confirmation'),
        headers: _getHeaders(),
        body: jsonEncode({
          'username': username,
        }),
      );
      
      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to resend code');
      }
      
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('Error resending confirmation code: $e');
      rethrow;
    }
  }

  // Login with username and password
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: _getHeaders(),
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );
      
      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Login failed');
      }
      
      final tokens = jsonDecode(response.body);
      
      // Save tokens to secure storage
      await _saveTokens(tokens);
      
      // Save username for future reference
      await _secureStorage.write(key: 'username', value: username);
      
      // Try to get user info
      try {
        final userInfo = await getUserInfo();
        
        // Save user data
        final userData = {
          'username': username,
          'email': userInfo['email'],
          if (userInfo['name'] != null) 'name': userInfo['name'],
          'lastLogin': DateTime.now().toIso8601String(),
        };
        
        await _secureStorage.write(key: 'user_data', value: jsonEncode(userData));
      } catch (e) {
        // Non-fatal error - we still have the tokens
        debugPrint('Error getting user info after login: $e');
      }
      
      return tokens;
    } catch (e) {
      debugPrint('Error during login: $e');
      rethrow;
    }
  }

  // Forgot password - request reset code
  Future<Map<String, dynamic>> forgotPassword({
    required String username,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: _getHeaders(),
        body: jsonEncode({
          'username': username,
        }),
      );
      
      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Forgot password request failed');
      }
      
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('Error during forgot password: $e');
      rethrow;
    }
  }

  // Reset password with confirmation code
  Future<Map<String, dynamic>> resetPassword({
    required String username,
    required String confirmationCode,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: _getHeaders(),
        body: jsonEncode({
          'username': username,
          'confirmation_code': confirmationCode,
          'new_password': newPassword,
        }),
      );
      
      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Password reset failed');
      }
      
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('Error resetting password: $e');
      rethrow;
    }
  }

  // Reset password with confirmation code - alias method to match UI expectations
  Future<Map<String, dynamic>> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    return resetPassword(
      username: email,
      confirmationCode: code,
      newPassword: newPassword,
    );
  }

  // Refresh the authentication token
  Future<Map<String, dynamic>> refreshAuthToken(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/refresh-token'),
        headers: _getHeaders(),
        body: jsonEncode({
          'refresh_token': refreshToken,
        }),
      );
      
      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Token refresh failed');
      }
      
      final tokens = jsonDecode(response.body);
      
      // Update stored tokens
      await _saveTokens(tokens);
      
      return tokens;
    } catch (e) {
      debugPrint('Error refreshing token: $e');
      rethrow;
    }
  }

  // Logout the user
  Future<void> logout() async {
    try {
      final accessToken = await _secureStorage.read(key: 'access_token');
      
      if (accessToken != null) {
        try {
          final response = await http.post(
            Uri.parse('$baseUrl/logout'),
            headers: _getHeaders(),
            body: jsonEncode({
              'access_token': accessToken,
            }),
          );
          
          if (response.statusCode != 200) {
            debugPrint('Logout from server failed: ${response.body}');
            // Continue with local logout even if server logout fails
          }
        } catch (e) {
          debugPrint('Error during server logout: $e');
          // Continue with local logout
        }
      }
      
      // Always clear local tokens
      await _clearTokens();
    } catch (e) {
      debugPrint('Error during logout: $e');
      rethrow;
    }
  }

  // Get user information
  Future<Map<String, dynamic>> getUserInfo() async {
    try {
      final accessToken = await _secureStorage.read(key: 'access_token');
      
      if (accessToken == null) {
        throw Exception('Not authenticated');
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/user-info'),
        headers: {
          ..._getHeaders(),
          'access_token': accessToken,
        },
      );
      
      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to get user info');
      }
      
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('Error getting user info: $e');
      rethrow;
    }
  }

  // Register a new device
  Future<Map<String, dynamic>> registerDevice({
    required String deviceId,
    required String deviceName,
    required String deviceType,
    String? location,
  }) async {
    try {
      final accessToken = await _secureStorage.read(key: 'access_token');
      
      if (accessToken == null) {
        throw Exception('Not authenticated');
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/register-device'),
        headers: {
          ..._getHeaders(),
          'access_token': accessToken,
        },
        body: jsonEncode({
          'device_id': deviceId,
          'device_name': deviceName,
          'device_type': deviceType,
          if (location != null) 'location': location,
        }),
      );
      
      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to register device');
      }
      
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('Error registering device: $e');
      rethrow;
    }
  }

  // List devices for the current user
  Future<List<Map<String, dynamic>>> listDevices() async {
    try {
      final accessToken = await _secureStorage.read(key: 'access_token');
      
      if (accessToken == null) {
        throw Exception('Not authenticated');
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/list-devices'),
        headers: {
          ..._getHeaders(),
          'access_token': accessToken,
        },
      );
      
      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to list devices');
      }
      
      final List<dynamic> devices = jsonDecode(response.body);
      return devices.map((device) => device as Map<String, dynamic>).toList();
    } catch (e) {
      debugPrint('Error listing devices: $e');
      rethrow;
    }
  }
}
