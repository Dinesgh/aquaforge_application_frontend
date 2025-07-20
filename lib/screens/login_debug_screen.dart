import 'package:flutter/material.dart';
import '../services/direct_cognito_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class LoginDebugScreen extends StatefulWidget {
  const LoginDebugScreen({Key? key}) : super(key: key);

  @override
  State<LoginDebugScreen> createState() => _LoginDebugScreenState();
}

class _LoginDebugScreenState extends State<LoginDebugScreen> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  // Save authentication tokens securely
  Future<void> _saveTokens({
    required String idToken,
    required String accessToken,
    required String refreshToken,
    required String username,
  }) async {
    try {
      // Store tokens securely
      await _secureStorage.write(key: 'id_token', value: idToken);
      await _secureStorage.write(key: 'access_token', value: accessToken);
      await _secureStorage.write(key: 'refresh_token', value: refreshToken);
      await _secureStorage.write(key: 'username', value: username);
      
      // Store user data
      final Map<String, dynamic> userData = {
        'username': username,
        'lastLogin': DateTime.now().toIso8601String(),
        'authMethod': 'direct_api',
      };
      
      await _secureStorage.write(key: 'user_data', value: json.encode(userData));
      debugPrint('Tokens and user data saved successfully');
    } catch (e) {
      debugPrint('Error saving tokens: $e');
      // Non-fatal error - user can still proceed
    }
  }
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _cognitoService = DirectCognitoAuthService();
  
  String _result = '';
  bool _isLoading = false;
  bool _showAdvancedOptions = false;
  bool _obscurePassword = true;
  
  Future<void> _attemptLogin() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _result = 'Please enter both username and password';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _result = 'Attempting login...';
    });
    
    try {
      final username = _usernameController.text.trim();
      final password = _passwordController.text;
      
      debugPrint('DEBUG LOGIN: Attempting login with username: $username');
      
      final response = await _cognitoService.signIn(
        username: username,
        password: password,
      );
      
      // Extract the tokens
      final idToken = response["AuthenticationResult"]["IdToken"].toString();
      final accessToken = response["AuthenticationResult"]["AccessToken"].toString();
      final refreshToken = response["AuthenticationResult"]["RefreshToken"].toString();
      
      setState(() {
        _result = 'LOGIN SUCCESS!\n\nToken received:\n${idToken.substring(0, 20)}...';
      });
      
      // Save the tokens securely
      await _saveTokens(
        idToken: idToken,
        accessToken: accessToken, 
        refreshToken: refreshToken,
        username: username,
      );
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful! Navigating to dashboard...'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      
      // Navigate to dashboard after short delay
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacementNamed(context, '/dashboard');
      });
    } catch (e) {
      setState(() {
        _result = 'Error: ${e.toString()}';
      });
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: ${e.toString().replaceAll("Exception: ", "")}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 8),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Debug Tool'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Warning banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade300),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Login Debug Tool',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    Text('This tool uses direct API calls to AWS Cognito, bypassing the Amplify SDK.'),
                    Text('Use this to verify if your account can log in.'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Email / Username',
                  hintText: 'Enter your email address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _attemptLogin,
                icon: const Icon(Icons.login),
                label: const Text('Login (Direct API)'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
              
              const SizedBox(height: 12),
              
              TextButton(
                onPressed: () {
                  setState(() {
                    _showAdvancedOptions = !_showAdvancedOptions;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_showAdvancedOptions ? Icons.expand_less : Icons.expand_more, size: 16),
                    const SizedBox(width: 4),
                    Text(_showAdvancedOptions ? 'Hide Advanced Options' : 'Show Advanced Options'),
                  ],
                ),
              ),
              
              if (_showAdvancedOptions) ...[
                const Divider(),
                Text('Client ID: ${_cognitoService.clientId}'),
                Text('User Pool ID: ${_cognitoService.userPoolId}'),
                Text('Region: ${_cognitoService.region}'),
                const Divider(),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/direct-cognito-test');
                  },
                  child: const Text('Go to Account Confirmation Page'),
                ),
              ],
              
              const SizedBox(height: 24),
              
              const Text('Result:'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _isLoading 
                  ? const Center(child: CircularProgressIndicator()) 
                  : Text(_result),
              ),
              
              const SizedBox(height: 24),
              
              // Login troubleshooting guide
              ExpansionTile(
                title: const Text('Login Troubleshooting Tips'),
                tilePadding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('• Make sure you have confirmed your account via email', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('• Your username must be your email address'),
                        Text('• Passwords are case sensitive'),
                        Text('• Check for typos in your email and password'),
                        Text('• If you get "User not confirmed", go to confirmation page'),
                        Text('• If you get "Network error", check your internet connection'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
