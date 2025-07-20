// screens/device_registration_screen.dart
import 'package:flutter/material.dart';
import '../services/device_service.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../config/api_config.dart';

class DeviceRegistrationScreen extends StatefulWidget {
  const DeviceRegistrationScreen({super.key});

  @override
  State<DeviceRegistrationScreen> createState() => _DeviceRegistrationScreenState();
}

class _DeviceRegistrationScreenState extends State<DeviceRegistrationScreen> {
  final TextEditingController _deviceIdController = TextEditingController();
  final TextEditingController _deviceNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String _deviceType = 'sensor';  // Default device type
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  final List<String> _deviceTypes = ['sensor', 'controller', 'gateway', 'other'];

  @override
  void dispose() {
    _deviceIdController.dispose();
    _deviceNameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _registerDevice() async {
    // Validate form
    if (_deviceIdController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Device ID is required';
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
      // Get authentication service
      final authService = Provider.of<AuthService>(context, listen: false);
      
      // Create device service
      final deviceService = DeviceService(
        apiUrl: ApiConfig.baseApiUrl,  // Using the centralized config
        authService: authService,
      );
      
      // Register the device
      await deviceService.registerDevice(
        deviceId: _deviceIdController.text.trim(),
        deviceName: _deviceNameController.text.trim().isNotEmpty 
            ? _deviceNameController.text.trim() : null,
        deviceType: _deviceType,
        location: _locationController.text.trim().isNotEmpty 
            ? _locationController.text.trim() : null,
      );
      
      setState(() {
        _successMessage = 'Device registered successfully!';
        // Clear form after successful registration
        _deviceIdController.clear();
        _deviceNameController.clear();
        _locationController.clear();
        _deviceType = 'sensor';
      });
      
      // Show dialog with success message and options
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Device Registered'),
          content: const Text('Your device has been successfully registered to your account. You can now log in to start using the application.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pushReplacementNamed(context, '/login'); // Go to login screen
              },
              child: const Text('Continue to Login'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: const Text('Register Another Device'),
            ),
          ],
        ),
      );
      
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Device'),
      ),
      body: Center(
        child: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Header icon
                Icon(
                  Icons.devices,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 20),
                Text(
                  'Register New Device',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColorDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                
                // Form fields
                TextField(
                  controller: _deviceIdController,
                  decoration: const InputDecoration(
                    labelText: 'Device ID *',
                    prefixIcon: Icon(Icons.qr_code),
                    helperText: 'Enter the unique identifier of your device',
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                
                TextField(
                  controller: _deviceNameController,
                  decoration: const InputDecoration(
                    labelText: 'Device Name (Optional)',
                    prefixIcon: Icon(Icons.label),
                    helperText: 'A friendly name for your device',
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                
                // Device Type dropdown
                DropdownButtonFormField<String>(
                  value: _deviceType,
                  decoration: const InputDecoration(
                    labelText: 'Device Type',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: _deviceTypes.map((type) => 
                    DropdownMenuItem(
                      value: type,
                      child: Text(type[0].toUpperCase() + type.substring(1)),
                    )
                  ).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _deviceType = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                
                TextField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location (Optional)',
                    prefixIcon: Icon(Icons.location_on),
                    helperText: 'Where the device is installed',
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _registerDevice(),
                ),
                
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                  
                if (_successMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      _successMessage!,
                      style: const TextStyle(color: Colors.green, fontSize: 14),
                    ),
                  ),
                
                const SizedBox(height: 30),
                
                _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _registerDevice,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        'Register Device',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                
                const SizedBox(height: 16),
                
                TextButton(
                  onPressed: () {
                    // Show confirmation dialog
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Skip Device Registration'),
                        content: const Text('Are you sure you want to skip device registration? You can always add a device later from your dashboard.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Close dialog
                            },
                            child: const Text('Continue Registration'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context); // Close dialog
                              Navigator.pushReplacementNamed(context, '/login'); // Go to login
                            },
                            child: const Text('Skip Registration'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text(
                    'Skip for now',
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
