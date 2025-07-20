import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

/// Auth Helper class to centralize authentication-related functionality
/// This allows us to share token handling between Amplify SDK and Direct API approaches
class AuthHelper {
  static final AuthHelper _instance = AuthHelper._internal();
  factory AuthHelper() => _instance;
  AuthHelper._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Check if user is authenticated - works with both auth methods
  Future<bool> isAuthenticated() async {
    try {
      // First check for a token
      final idToken = await _secureStorage.read(key: 'id_token');
      if (idToken == null || idToken.isEmpty) {
        return false;
      }
      
      // TODO: For production, you would validate token expiration here
      
      return true;
    } catch (e) {
      debugPrint('Error checking authentication: $e');
      return false;
    }
  }
  
  /// Get the username of the currently authenticated user
  Future<String?> getCurrentUsername() async {
    try {
      return await _secureStorage.read(key: 'username');
    } catch (e) {
      debugPrint('Error getting username: $e');
      return null;
    }
  }
  
  /// Get user data from secure storage
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final userData = await _secureStorage.read(key: 'user_data');
      if (userData != null) {
        return json.decode(userData);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user data: $e');
      return null;
    }
  }

  /// Log out the user - clears all stored credentials
  Future<void> logout() async {
    try {
      await _secureStorage.delete(key: 'id_token');
      await _secureStorage.delete(key: 'access_token');
      await _secureStorage.delete(key: 'refresh_token');
      await _secureStorage.delete(key: 'username');
      await _secureStorage.delete(key: 'user_data');
      debugPrint('User logged out successfully');
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
  }

  /// Handle authentication redirects - use in any screen to ensure user is authenticated
  static Future<void> ensureAuthenticated(BuildContext context) async {
    final authHelper = AuthHelper();
    final isAuthenticated = await authHelper.isAuthenticated();
    
    if (!isAuthenticated && context.mounted) {
      // Redirect to login screen if not authenticated
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
}
