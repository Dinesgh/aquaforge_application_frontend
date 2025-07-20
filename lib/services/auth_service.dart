import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../amplifyconfiguration.dart' as config;

class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  // Client ID and secret for your Cognito app client - exact values from AWS Console
  final String _clientId = '7iqtgp2u4esgc5ts56pqmjft4b';
  final String _clientSecret = 'nja1jtili5jc2101u2s8gok0bbhmii809a848io0lc2hrb2qb8d';
  
  // Method to calculate SECRET_HASH according to AWS documentation
  String _calculateSecretHash(String username) {
    // Per AWS documentation: username + clientId
    final String message = username + _clientId; // Use the class property
    final key = utf8.encode(_clientSecret);
    final bytes = utf8.encode(message);
    
    // Use HMAC SHA-256 hash with correct key
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);
    
    // Base64 encode the result
    final hash = base64.encode(digest.bytes);
    debugPrint('Generated SECRET_HASH: $hash for user: $username');
    return hash;
  }
  
  AuthService();
  
  // Check if we are using a client with a secret and need SECRET_HASH
  bool get _isUsingClientWithSecret => _clientSecret.isNotEmpty;
  
  // Get client status message for debugging
  String getClientStatus() {
    if (_isUsingClientWithSecret) {
      return 'Using Cognito app client with secret (requires SECRET_HASH). Client ID: $_clientId, Secret Length: ${_clientSecret.length}';
    } else {
      return 'Using Cognito app client without secret. Client ID: $_clientId';
    }
  }

  // Configure Amplify - call this at app startup
  Future<void> configureAmplify() async {
    try {
      // Check if Amplify is already configured
      final isConfigured = Amplify.isConfigured;
      if (isConfigured) return;
      
      try {
        // NOTE: This code assumes that the Amplify Auth Cognito plugin is added
        // in the main.dart file or elsewhere before this method is called
        
        // Configure Amplify with the string configuration
        await Amplify.configure(config.amplifyconfig);
        
        debugPrint('Successfully configured Amplify');
        debugPrint(getClientStatus());
        
        // Validate that the configuration worked by checking if we're signed in
        try {
          final session = await Amplify.Auth.fetchAuthSession();
          debugPrint('Auth session check: ${session.isSignedIn ? 'Signed in' : 'Not signed in'}');
        } catch (sessionError) {
          debugPrint('Could not fetch auth session: $sessionError');
        }
      } catch (configError) {
        debugPrint('Error configuring Amplify: $configError');
        throw Exception('Failed to configure Amplify. Check your configuration.');
      }
    } catch (e) {
      debugPrint('Error configuring Amplify: $e');
      rethrow;
    }
  }

  // Store user data in secure storage
  Future<void> _storeUserData(Map<String, dynamic> userData) async {
    await _storage.write(key: 'user_data', value: json.encode(userData));
  }
  
  // Get stored user data
  Future<Map<String, dynamic>?> getUserData() async {
    final userDataString = await _storage.read(key: 'user_data');
    if (userDataString != null) {
      return json.decode(userDataString);
    }
    return null;
  }
  
  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      return session.isSignedIn;
    } catch (e) {
      debugPrint('Error checking auth status: $e');
      return false;
    }
  }

  // Sign up a new user - using proper SECRET_HASH approach
  Future<void> signUp({
    required String username,
    required String password,
    required String email,
    String? name,
  }) async {
    try {
      // IMPORTANT: For this user pool, username must be an email address
      // If username is not an email but email is, use email as username
      if (!username.contains('@') && email.contains('@')) {
        debugPrint('Username must be an email in this user pool - using email as username');
        username = email;
      }
      
      // Create map of user attributes
      final userAttributes = <AuthUserAttributeKey, String>{
        AuthUserAttributeKey.email: email,
        if (name != null) AuthUserAttributeKey.name: name,
        // Add any other required attributes
      };
      
      // Calculate SECRET_HASH
      final secretHash = _calculateSecretHash(username);
      
      debugPrint('Using SECRET_HASH: $secretHash for username: $username');
      debugPrint('Client ID: $_clientId');
      debugPrint('Client Secret (length): ${_clientSecret.length}');
      
      // Try to use all available options to pass SECRET_HASH
      final result = await Amplify.Auth.signUp(
        username: username,
        password: password,
        options: SignUpOptions(
          userAttributes: userAttributes,
          pluginOptions: CognitoSignUpPluginOptions(
            validationData: {
              'SECRET_HASH': secretHash,
            },
            // Use clientMetadata to also try passing SECRET_HASH
            clientMetadata: {
              'SECRET_HASH': secretHash,
            },
          ),
        ),
      );
      
      if (result.isSignUpComplete) {
        // Store basic user data
        await _storeUserData({
          'username': username,
          'email': email,
          if (name != null) 'name': name,
        });
      }
    } catch (e) {
      debugPrint('Error signing up: $e');
      
      // Check if it's a SECRET_HASH error
      if (e.toString().contains('SECRET_HASH')) {
        debugPrint('SECRET_HASH issue detected - falling back to direct API');
        try {
          // Recommend using the direct API test page as fallback
          throw Exception('SECRET_HASH error. Please try using the Direct Cognito Test Page or create an app client without a secret.');
        } catch (fallbackError) {
          debugPrint('Fallback error: $fallbackError');
          throw fallbackError;
        }
      }
      
      rethrow;
    }
  }
  
  // Confirm sign up with verification code
  Future<void> confirmSignUp({
    required String username,
    required String confirmationCode,
  }) async {
    try {
      await Amplify.Auth.confirmSignUp(
        username: username,
        confirmationCode: confirmationCode,
      );
    } catch (e) {
      debugPrint('Error confirming sign up: $e');
      rethrow;
    }
  }
  
  // Login user with enhanced SECRET_HASH handling and better error recovery
  Future<void> login({
    required String username,
    required String password,
    String? email,
  }) async {
    try {
      // IMPORTANT: For this user pool, username must be an email address
      // If username is not an email but email is provided, use email as username
      if (!username.contains('@') && email != null && email.contains('@')) {
        debugPrint('Username must be an email in this user pool - using email as username');
        username = email;
      } else if (!username.contains('@')) {
        throw Exception('Username must be an email address. Please use your email to login.');
      }
      
      // Calculate SECRET_HASH
      final secretHash = _calculateSecretHash(username);
      
      // Debugging information
      debugPrint('Login attempt for username: $username');
      debugPrint('Using SECRET_HASH: $secretHash');
      
      // First attempt: Standard approach with client metadata
      debugPrint('Trying login with SECRET_HASH in clientMetadata...');
      final result = await Amplify.Auth.signIn(
        username: username,
        password: password,
        options: SignInOptions(
          pluginOptions: CognitoSignInPluginOptions(
            clientMetadata: {
              'SECRET_HASH': secretHash,
              'SecretHash': secretHash  // Try both formats
            }
          )
        )
      );
      
      
      if (result.isSignedIn) {
        debugPrint('Successfully signed in user: $username');
        // Get user details and store
        try {
          final user = await Amplify.Auth.getCurrentUser();
          final attributes = await Amplify.Auth.fetchUserAttributes();
          
          final Map<String, dynamic> userData = {
            'username': user.username,
          };
          
          // Map user attributes to our storage format
          for (final attribute in attributes) {
            if (attribute.userAttributeKey == AuthUserAttributeKey.email) {
              userData['email'] = attribute.value;
            } else if (attribute.userAttributeKey == AuthUserAttributeKey.name) {
              userData['name'] = attribute.value;
            }
          }
          
          await _storeUserData(userData);
        } catch (e) {
          debugPrint('Error fetching user data: $e');
        }
      }
    } catch (e) {
      debugPrint('Error signing in: $e');
      
      // Check if it's a SECRET_HASH error
      if (e.toString().contains('SECRET_HASH')) {
        debugPrint('SECRET_HASH issue detected during login - suggesting fallback');
        throw Exception('SECRET_HASH error during login. Please try using the Direct Cognito Test Page or create an app client without a secret.');
      }
      
      // Check if it's a UserNotConfirmedException - offer verification instructions
      if (e.toString().contains('UserNotConfirmedException')) {
        debugPrint('User not confirmed - need to verify email');
        throw Exception('Your account is not confirmed. Please check your email for a verification link and complete the verification process.');
      }
      
      // Use our custom error handler for better error messages
      final errorMessage = _parseAuthError(e);
      throw Exception(errorMessage);
    }
  }
  
  // Logout user
  Future<void> logout() async {
    try {
      await Amplify.Auth.signOut();
      await _storage.delete(key: 'user_data');
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }
  
  // Get current authenticated user
  Future<AuthUser> getCurrentUser() async {
    try {
      final user = await Amplify.Auth.getCurrentUser();
      return user;
    } catch (e) {
      debugPrint('Error getting current user: $e');
      rethrow;
    }
  }
  
  // Reset password
  Future<void> resetPassword({required String username}) async {
    try {
      await Amplify.Auth.resetPassword(username: username);
    } catch (e) {
      debugPrint('Error resetting password: $e');
      rethrow;
    }
  }
  
  // Confirm password reset
  Future<void> confirmResetPassword({
    required String username,
    required String newPassword,
    required String confirmationCode,
  }) async {
    try {
      await Amplify.Auth.confirmResetPassword(
        username: username,
        newPassword: newPassword,
        confirmationCode: confirmationCode,
      );
    } catch (e) {
      debugPrint('Error confirming password reset: $e');
      rethrow;
    }
  }

  // Get current user's Cognito ID (sub)
  Future<String?> getCurrentUserId() async {
    try {
      final attributes = await Amplify.Auth.fetchUserAttributes();
      
      for (final attribute in attributes) {
        if (attribute.userAttributeKey == AuthUserAttributeKey.sub) {
          return attribute.value;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user ID: $e');
      return null;
    }
  }
  
  // Get current user's email
  Future<String?> getCurrentUserEmail() async {
    try {
      final attributes = await Amplify.Auth.fetchUserAttributes();
      
      for (final attribute in attributes) {
        if (attribute.userAttributeKey == AuthUserAttributeKey.email) {
          return attribute.value;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user email: $e');
      return null;
    }
  }

  // Helper method to parse Cognito errors
  String _parseAuthError(dynamic error) {
    final errorString = error.toString();
    
    // Network-related errors
    if (errorString.contains('NetworkException') || 
        errorString.contains('network error') || 
        errorString.contains('Failed to fetch')) {
      return 'Network error: Please check your internet connection and verify AWS region settings';
    }
    
    // Authentication-related errors
    if (errorString.contains('UserNotFoundException')) {
      return 'User not found';
    } else if (errorString.contains('NotAuthorizedException')) {
      return 'Incorrect username or password';
    } else if (errorString.contains('UserNotConfirmedException')) {
      return 'Please verify your email before logging in';
    } else if (errorString.contains('LimitExceededException')) {
      return 'Too many attempts. Please try again later';
    }
    
    // SECRET_HASH errors
    if (errorString.contains('SECRET_HASH')) {
      return 'SECRET_HASH error. Please try using the Direct Cognito Test Page or create an app client without a secret.';
    }
    
    // Configuration errors
    if (errorString.contains('InvalidParameterException') || 
        errorString.contains('InvalidClientMetadata')) {
      return 'Authentication configuration error. Please contact support';
    }
    
    // Return a generic error if none of the above match
    return errorString.replaceFirst('Exception: ', '');
  }
  
  // Print detailed debug information about the current configuration
  void printDebugInfo() {
    debugPrint('========= COGNITO DEBUG INFO =========');
    debugPrint('Client ID: $_clientId');
    debugPrint('Client Secret (first 5 chars): ${_clientSecret.substring(0, 5)}...');
    debugPrint('Client Secret Length: ${_clientSecret.length}');
    debugPrint('Using client with secret: $_isUsingClientWithSecret');
    debugPrint('Amplify configured: ${Amplify.isConfigured}');
    
    // Also print the raw config (redacting sensitive info)
    final configStr = config.amplifyconfig;
    debugPrint('Amplify config contains UserPool: ${configStr.contains("PoolId")}');
    debugPrint('====================================');
  }
}
