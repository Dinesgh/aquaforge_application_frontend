import 'package:flutter/material.dart';
import '../services/direct_cognito_service.dart';

// This is a simple test page to try the direct Cognito API approach
// You can add this to your routes and navigate to it for testing
class DirectCognitoTestPage extends StatefulWidget {
  const DirectCognitoTestPage({super.key});

  @override
  State<DirectCognitoTestPage> createState() => _DirectCognitoTestPageState();
}

class _DirectCognitoTestPageState extends State<DirectCognitoTestPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _confirmationCodeController = TextEditingController();
  final _cognitoService = DirectCognitoAuthService();
  
  String _result = '';
  bool _isLoading = false;
  bool _showConfirmation = false;

  @override
  void initState() {
    super.initState();
    
    // Listen for username changes and update email to match automatically
    _usernameController.addListener(_syncEmailToUsername);
  }

  // Keep email in sync with username since they must be the same for this user pool
  void _syncEmailToUsername() {
    if (_usernameController.text.contains('@')) {
      _emailController.text = _usernameController.text;
    }
  }

  @override
  void dispose() {
    _usernameController.removeListener(_syncEmailToUsername);
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _confirmationCodeController.dispose();
    super.dispose();
  }
  
  // Handle user confirmation
  Future<void> _confirmSignUp() async {
    if (_usernameController.text.isEmpty || _confirmationCodeController.text.isEmpty) {
      setState(() {
        _result = 'Username and confirmation code are required';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _result = 'Confirming registration...';
    });
    
    try {
      final username = _usernameController.text.contains('@') 
          ? _usernameController.text 
          : _emailController.text;
          
      final response = await _cognitoService.confirmSignUp(
        username: username,
        confirmationCode: _confirmationCodeController.text,
      );
      
      setState(() {
        _result = 'Account confirmed successfully! You can now sign in.';
        _showConfirmation = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account confirmed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _result = 'Error confirming account: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signUp() async {
    if (_usernameController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _emailController.text.isEmpty) {
      setState(() {
        _result = 'Please fill in all fields';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _result = 'Signing up...';
    });

    try {
      final response = await _cognitoService.signUp(
        username: _usernameController.text,
        password: _passwordController.text,
        email: _emailController.text,
      );

      setState(() {
        _result = 'Success! Response: $response';
      });
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signIn() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _result = 'Username and password required';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _result = 'Signing in...';
    });

    try {
      // Make sure we're using an email address as the username
      final username = _usernameController.text.contains('@') 
          ? _usernameController.text 
          : _emailController.text;
          
      debugPrint('Attempting login with username (email): $username');
      
      final response = await _cognitoService.signIn(
        username: username,
        password: _passwordController.text,
      );

      setState(() {
        _result = 'Login Successful!\n\nToken info: ${response["AuthenticationResult"]["IdToken"].substring(0, 20)}...';
      });
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
      
    } catch (e) {
      setState(() {
        // Format the error message for better readability
        String errorMsg = e.toString();
        if (errorMsg.contains('UserNotConfirmedException')) {
          _result = 'Error: Your account is not confirmed. Please check your email for a verification link.';
        } else if (errorMsg.contains('NotAuthorizedException')) {
          _result = 'Error: Incorrect username or password';
        } else if (errorMsg.contains('UserNotFoundException')) {
          _result = 'Error: User not found. Please check your email/username.';
        } else {
          _result = 'Error: $e';
        }
      });
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
        title: const Text('Direct Cognito Test'),
      ),
      // Add info banner for client details
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Using ClientId: ${_cognitoService.clientId}\nSecret: ${_cognitoService.clientSecret.substring(0, 5)}...',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              const Text(
                'If you received verification code by email, use the "Need to confirm your account?" button',
                style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Add warning banner about username requirement
              Container(
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.only(bottom: 12.0),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.amber),
                ),
                child: const Text(
                  'IMPORTANT: Username must be an email address in this User Pool',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username (must be email)',
                  hintText: 'user@example.com',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Same as username',
                ),
              ),
              const SizedBox(height: 24),
              
              // Show confirmation code field if in confirmation mode
              if (_showConfirmation) ...[
                TextField(
                  controller: _confirmationCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Confirmation Code',
                    hintText: 'Enter the code from your email',
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _confirmSignUp,
                  child: const Text('Confirm Account'),
                ),
                // Add a button to resend the confirmation code
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _isLoading 
                            ? null 
                            : () async {
                                if (_usernameController.text.isEmpty) {
                                  setState(() {
                                    _result = 'Username is required to resend code';
                                  });
                                  return;
                                }
                                
                                setState(() {
                                  _isLoading = true;
                                  _result = 'Requesting new code...';
                                });
                                
                                try {
                                  await _cognitoService.resendConfirmationCode(
                                    username: _usernameController.text,
                                  );
                                  
                                  setState(() {
                                    _result = 'New verification code sent to your email. Please check your inbox and enter the new code.';
                                  });
                                } catch (e) {
                                  setState(() {
                                    _result = 'Error: $e';
                                  });
                                } finally {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                }
                              },
                        child: const Text('Resend Code'),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _showConfirmation = false;
                          });
                        },
                        child: const Text('Back to Sign In/Up'),
                      ),
                    ),
                  ],
                ),
                // Help text for users
                const Padding(
                  padding: EdgeInsets.only(top: 12.0),
                  child: Text(
                    'If your code doesn\'t work, it may have expired. Use "Resend Code" to get a new one.',
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ),
              ] else ...[
                ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
                  child: const Text('Sign Up (Direct API)'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _signIn,
                  child: const Text('Sign In (Direct API)'),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _showConfirmation = true;
                          });
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.amber.shade100,
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        ),
                        child: const Text(
                          'Need to confirm your account?',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login-debug');
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.blue.shade100,
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        ),
                        child: const Text(
                          'Try Login Debug Tool',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              const Text('Result:'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(_result),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
