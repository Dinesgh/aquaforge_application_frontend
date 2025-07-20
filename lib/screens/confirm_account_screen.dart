// screens/confirm_account_screen.dart
import 'package:flutter/material.dart';
import '../services/backend_auth_client.dart';

class ConfirmAccountScreen extends StatefulWidget {
  const ConfirmAccountScreen({super.key});

  @override
  State<ConfirmAccountScreen> createState() => _ConfirmAccountScreenState();
}

class _ConfirmAccountScreenState extends State<ConfirmAccountScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _confirmationCodeController = TextEditingController();
  
  final BackendAuthClient _authClient = BackendAuthClient();
  
  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;
  String? _successMessage;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Check if username was passed from registration screen
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is String) {
      _usernameController.text = args;
    }
  }
  
  Future<void> _confirmAccount() async {
    // Validate form
    if (_usernameController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email address';
        _successMessage = null;
      });
      return;
    }
    
    if (_confirmationCodeController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter the verification code';
        _successMessage = null;
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });
    
    try {
      await _authClient.confirmRegistration(
        username: _usernameController.text.trim(),
        confirmationCode: _confirmationCodeController.text.trim(),
      );
      
      setState(() {
        _successMessage = 'Account confirmed successfully! You can now log in.';
      });
      
      // Show success dialog with device registration option
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Account Confirmed'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your account has been verified successfully.'),
                SizedBox(height: 12),
                Text('Would you like to register an IoT device with your account now?'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text('Go to Login'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pushReplacementNamed(context, '/register-device');
                },
                child: const Text('Register Device'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _resendConfirmationCode() async {
    if (_usernameController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email address';
        _successMessage = null;
      });
      return;
    }
    
    setState(() {
      _isResending = true;
      _errorMessage = null;
      _successMessage = null;
    });
    
    try {
      await _authClient.resendConfirmationCode(
        username: _usernameController.text.trim(),
      );
      
      setState(() {
        _successMessage = 'A new verification code has been sent to your email.';
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isResending = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Your Account'),
      ),
      body: Center(
        child: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon
                Icon(
                  Icons.verified_user,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 20),
                
                const Text(
                  'Verify Your Account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                
                const Text(
                  'Enter the verification code sent to your email address to complete registration.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                
                Container(
                  padding: const EdgeInsets.all(12.0),
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Check your inbox and spam folders for the verification email.',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                
                const Text(
                  'Enter the verification code that was sent to your email address.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                
                // Username field
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    prefixIcon: Icon(Icons.email),
                    hintText: 'Enter your email address',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 20),
                
                // Confirmation code field
                TextField(
                  controller: _confirmationCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Verification Code *',
                    prefixIcon: Icon(Icons.security),
                    hintText: 'Enter the code from your email',
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _confirmAccount(),
                ),
                const SizedBox(height: 20),
                
                // Error/Success message
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                
                if (_successMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _successMessage!,
                      style: const TextStyle(color: Colors.green),
                      textAlign: TextAlign.center,
                    ),
                  ),
                
                // Confirm button
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _confirmAccount,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        child: const Text('Verify Account'),
                      ),
                
                const SizedBox(height: 16),
                
                // Resend code button
                _isResending
                    ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                    : TextButton.icon(
                        onPressed: _resendConfirmationCode,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Resend Verification Code'),
                      ),
                
                const SizedBox(height: 16),
                
                // Back to login link
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Go back to login
                  },
                  child: Text(
                    'Back to Login',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
