// Production configuration for AquaForge Flutter App
import 'package:flutter/foundation.dart';

class AppConfig {
  static const String apiBaseUrl = kDebugMode
      ? 'http://localhost:8000'
      : 'https://api.aquaforge.example.com';  // Replace with your actual production API URL
      
  static const bool useMockData = false; // Never use mock data in production
  
  static const String googleMapsApiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY', 
      defaultValue: 'YOUR_GOOGLE_MAPS_API_KEY'); // Replace this with your key for development
  
  static const String appVersion = '1.0.0';
  
  // Timeout values (in milliseconds)
  static const int connectionTimeout = 15000;
  static const int receiveTimeout = 15000;
  
  // Feature flags
  static const bool enableOfflineMode = true;
  static const bool enablePushNotifications = true;
  static const bool enableAnalytics = true;
  
  // Maximum number of retry attempts for API calls
  static const int maxRetryAttempts = 3;
  
  // Cache expiration time (in minutes)
  static const int cacheExpirationMinutes = 60;
}
