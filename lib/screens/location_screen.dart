import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/location_service.dart';
import 'dart:async';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final LocationService _locationService = LocationService();
  GoogleMapController? _mapController;
  final TextEditingController _deviceIdController = TextEditingController();
  
  bool _isLoading = false;
  LatLng? _deviceLocation;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    // Force use of mock service for reliable demo
    _locationService.setUseMockService(true);
  }

  // Create test device for demo purposes
  Future<void> _createTestDevice() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Create a test device at a default location
      await _locationService.updateDeviceLocation(
        deviceId: "test-device-001",
        latitude: 37.7749,
        longitude: -122.4194,
        locationName: "Test Device 1",
        description: "A test device in San Francisco"
      );
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test device created successfully')),
      );
      
      // Search for the test device
      _deviceIdController.text = "test-device-001";
      await _searchDevice();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating test device: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Fetch device location by ID
  Future<void> _searchDevice() async {
    final id = _deviceIdController.text.trim();
    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a device ID')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Try to get device location from the location service
      final location = await _locationService.getDeviceLocation(id);
      
      setState(() {
        _deviceLocation = LatLng(location.latitude, location.longitude);
        _isLoading = false;
      });
      
      // Animate the map to the device location
      if (_mapController != null && _deviceLocation != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(_deviceLocation!, 15),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Device not found: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _deviceIdController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_location),
            onPressed: _createTestDevice,
            tooltip: 'Create test device',
          ),
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/device-map');
            },
            tooltip: 'Open full map view',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _deviceIdController,
                    decoration: const InputDecoration(
                      labelText: 'Enter Device ID',
                      border: OutlineInputBorder(),
                      hintText: 'Search for a device by ID',
                    ),
                    onSubmitted: (_) => _searchDevice(),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _searchDevice,
                  icon: _isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ) 
                    : const Icon(Icons.search),
                  label: const Text('Search'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  initialCameraPosition: CameraPosition(
                    target: _deviceLocation ?? const LatLng(37.7749, -122.4194), // Default: San Francisco
                    zoom: 12,
                  ),
                  markers: _deviceLocation != null
                      ? {
                          Marker(
                            markerId: const MarkerId('device'),
                            position: _deviceLocation!,
                            infoWindow: InfoWindow(
                              title: 'Device ${_deviceIdController.text}',
                              snippet: 'Lat: ${_deviceLocation!.latitude.toStringAsFixed(4)}, '
                                  'Lng: ${_deviceLocation!.longitude.toStringAsFixed(4)}',
                            ),
                          ),
                        }
                      : {},
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  mapToolbarEnabled: true,
                ),
                if (_errorMessage != null)
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Error: $_errorMessage',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/device-map');
        },
        child: const Icon(Icons.map),
        tooltip: 'View all devices on map',
      ),
    );
  }
}