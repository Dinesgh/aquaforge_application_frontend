import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show debugPrint;

// This is a direct AWS Cognito API implementation that can be used
// if the Amplify SDK approach doesn't work
class DirectCognitoAuthService {
  // These values are from the AWS Console (verified July 7, 2025)
  final String userPoolId = 'us-east-1_VBU5vSzoh';
  final String clientId = '7iqtgp2u4esgc5ts56pqmjft4b';
  final String clientSecret = 'nja1jtili5jc2101u2s8gok0bbhmii809a848io0lc2hrb2qb8d';
  final String region = 'us-east-1';

  String calculateSecretHash(String username) {
    final message = username + clientId;
    final key = utf8.encode(clientSecret);
    final bytes = utf8.encode(message);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    return base64.encode(digest.bytes);
  }

  Future<Map<String, dynamic>> signUp({
    required String username,
    required String password,
    required String email,
  }) async {
    // IMPORTANT: For this user pool, the username must be an email address
    // If username is not an email but email is, use email as username
    if (!username.contains('@') && email.contains('@')) {
      debugPrint('Username must be an email in this user pool - using email as username');
      username = email;
    }
    
    final secretHash = calculateSecretHash(username);
    
    final endpoint = 'https://cognito-idp.$region.amazonaws.com/';
    
    final headers = {
      'Content-Type': 'application/x-amz-json-1.1',
      'X-Amz-Target': 'AWSCognitoIdentityProviderService.SignUp',
    };
    
    debugPrint('Sending signup request with username: $username (must be email format)');
    
    final body = {
      'ClientId': clientId,
      'Username': username,
      'Password': password,
      'SecretHash': secretHash,
      'UserAttributes': [
        {
          'Name': 'email',
          'Value': email,
        },
      ],
    };
    
    final response = await http.post(
      Uri.parse(endpoint),
      headers: headers,
      body: jsonEncode(body),
    );
    
    debugPrint('SignUp Response: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to sign up: ${response.body}');
    }
  }
  
  // Confirm a user registration with confirmation code
  Future<Map<String, dynamic>> confirmSignUp({
    required String username,
    required String confirmationCode,
  }) async {
    final secretHash = calculateSecretHash(username);
    
    final endpoint = 'https://cognito-idp.$region.amazonaws.com/';
    
    final headers = {
      'Content-Type': 'application/x-amz-json-1.1',
      'X-Amz-Target': 'AWSCognitoIdentityProviderService.ConfirmSignUp',
    };
    
    // Sanitize the confirmation code to remove any whitespace
    final sanitizedCode = confirmationCode.trim();
    
    debugPrint('Confirming signup for: $username with code length: ${sanitizedCode.length}');
    
    final body = {
      'ClientId': clientId,
      'Username': username,
      'ConfirmationCode': sanitizedCode,
      'SecretHash': secretHash,
    };
    
    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: headers,
        body: jsonEncode(body),
      );
      
      debugPrint('Confirm SignUp Response: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        return {'success': true, 'message': 'User confirmed successfully'};
      } else {
        // Parse error response for better user feedback
        final errorResponse = jsonDecode(response.body);
        final errorType = errorResponse['__type']?.toString().split('#').last;
        
        if (errorType == 'CodeMismatchException') {
          throw Exception('Invalid verification code. Please check your email for the correct code or request a new one.');
        } else if (errorType == 'ExpiredCodeException') {
          throw Exception('Verification code has expired. Please request a new code.');
        } else if (errorType == 'LimitExceededException') {
          throw Exception('Too many attempts. Please wait a while before trying again.');
        } else {
          throw Exception('Failed to confirm signup: ${response.body}');
        }
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }
  
  // Request a new confirmation code
  Future<Map<String, dynamic>> resendConfirmationCode({
    required String username,
  }) async {
    final secretHash = calculateSecretHash(username);
    
    final endpoint = 'https://cognito-idp.$region.amazonaws.com/';
    
    final headers = {
      'Content-Type': 'application/x-amz-json-1.1',
      'X-Amz-Target': 'AWSCognitoIdentityProviderService.ResendConfirmationCode',
    };
    
    final body = {
      'ClientId': clientId,
      'Username': username,
      'SecretHash': secretHash,
    };
    
    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: headers,
        body: jsonEncode(body),
      );
      
      debugPrint('Resend Code Response: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        return {'success': true, 'message': 'New confirmation code sent to your email'};
      } else {
        throw Exception('Failed to resend code: ${response.body}');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> signIn({
    required String username,
    required String password,
  }) async {
    final secretHash = calculateSecretHash(username);
    
    final endpoint = 'https://cognito-idp.$region.amazonaws.com/';
    
    final headers = {
      'Content-Type': 'application/x-amz-json-1.1',
      'X-Amz-Target': 'AWSCognitoIdentityProviderService.InitiateAuth',
    };
    
    final body = {
      'ClientId': clientId,
      'AuthFlow': 'USER_PASSWORD_AUTH',
      'AuthParameters': {
        'USERNAME': username,
        'PASSWORD': password,
        'SECRET_HASH': secretHash,
      },
    };
    
    debugPrint('Attempting login for: $username');
    debugPrint('Login request body (sanitized): {"ClientId":"$clientId","AuthFlow":"USER_PASSWORD_AUTH"}');
    
    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: headers,
        body: jsonEncode(body),
      );
      
      debugPrint('SignIn Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        debugPrint('Login successful!');
        return jsonDecode(response.body);
      } else {
        final responseBody = response.body;
        debugPrint('Login failed with response: $responseBody');
        
        // Parse the error for better handling
        final Map<String, dynamic> errorJson = jsonDecode(responseBody);
        final String? errorType = errorJson['__type']?.toString().split('#').last;
        
        if (errorType == 'UserNotConfirmedException') {
          throw Exception('Your account has not been confirmed yet. Please check your email for a verification code and use the "Need to confirm your account?" option.');
        } else if (errorType == 'NotAuthorizedException') {
          throw Exception('Incorrect username or password. Please try again.');
        } else if (errorType == 'UserNotFoundException') {
          throw Exception('User not found. Please check if you entered the correct email address.');
        } else {
          throw Exception('Failed to sign in: $responseBody');
        }
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }
}
