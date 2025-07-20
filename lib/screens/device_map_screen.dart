import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/device_location.dart';
import '../services/location_service.dart';
import 'dart:async';

class DeviceMapScreen extends StatefulWidget {
  const DeviceMapScreen({Key? key}) : super(key: key);

  @override
  State<DeviceMapScreen> createState() => _DeviceMapScreenState();
}

class _DeviceMapScreenState extends State<DeviceMapScreen> {
  final LocationService _locationService = LocationService();
  final Completer<GoogleMapController> _controller = Completer();
  
  bool _isLoading = true;
  String? _errorMessage;
  List<DeviceLocation> _deviceLocations = [];
  Set<Marker> _markers = {};
  
  // Default camera position - will be updated based on device locations
  CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(37.7749, -122.4194), // Default to San Francisco
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    _loadDeviceLocations();
  }
  
  Future<void> _loadDeviceLocations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    // Force use of mock service for reliable demo
    _locationService.setUseMockService(true);
    
    try {
      // Get all device locations
      final locations = await _locationService.getUserDevicesLocations();
      
      // Create markers
      final markers = locations.map((location) => 
        Marker(
          markerId: MarkerId(location.deviceId),
          position: LatLng(location.latitude, location.longitude),
          infoWindow: InfoWindow(
            title: location.locationName ?? 'Device ${location.deviceId}',
            snippet: location.description ?? 'Last updated: ${location.lastUpdated ?? 'Unknown'}',
          ),
        )
      ).toSet();
      
      // Update the camera position to the first device if available
      if (locations.isNotEmpty) {
        _initialCameraPosition = CameraPosition(
          target: LatLng(locations[0].latitude, locations[0].longitude),
          zoom: 14,
        );
      }
      
      setState(() {
        _deviceLocations = locations;
        _markers = markers;
        _isLoading = false;
      });
      
      // Update camera position if controller is ready
      if (_controller.isCompleted) {
        final controller = await _controller.future;
        controller.animateCamera(CameraUpdate.newCameraPosition(_initialCameraPosition));
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }
  
  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Locations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDeviceLocations,
            tooltip: 'Refresh Locations',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddLocationDialog(context),
        child: const Icon(Icons.add_location),
        tooltip: 'Add Location',
      ),
    );
  }
  
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error loading device locations',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDeviceLocations,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }
    
    if (_deviceLocations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No device locations found'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showAddLocationDialog(context),
              child: const Text('Add a Device Location'),
            ),
          ],
        ),
      );
    }
    
    return Column(
      children: [
        Expanded(
          child: GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: _initialCameraPosition,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapToolbarEnabled: true,
            zoomControlsEnabled: true,
          ),
        ),
        Container(
          height: 120,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _deviceLocations.length,
            itemBuilder: (context, index) {
              final location = _deviceLocations[index];
              return _buildDeviceLocationCard(location);
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildDeviceLocationCard(DeviceLocation location) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              location.locationName ?? 'Device ${location.deviceId}',
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              location.description ?? 'No description',
              style: TextStyle(color: Colors.grey[700]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Last update:',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                TextButton(
                  onPressed: () => _zoomToLocation(location),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 0),
                  ),
                  child: const Text('View'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _zoomToLocation(DeviceLocation location) async {
    final controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(location.latitude, location.longitude),
        16,
      ),
    );
  }
  
  void _showAddLocationDialog(BuildContext context) {
    final deviceIdController = TextEditingController();
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final latitudeController = TextEditingController();
    final longitudeController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Device Location'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: deviceIdController,
                  decoration: const InputDecoration(labelText: 'Device ID *'),
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Location Name'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: latitudeController,
                  decoration: const InputDecoration(labelText: 'Latitude *'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                TextField(
                  controller: longitudeController,
                  decoration: const InputDecoration(labelText: 'Longitude *'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Validate input
                if (deviceIdController.text.isEmpty ||
                    latitudeController.text.isEmpty ||
                    longitudeController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all required fields')),
                  );
                  return;
                }
                
                try {
                  final latitude = double.parse(latitudeController.text);
                  final longitude = double.parse(longitudeController.text);
                  
                  Navigator.of(context).pop();
                  
                  // Show loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Adding location...')),
                  );
                  
                  // Update location
                  await _locationService.updateDeviceLocation(
                    deviceId: deviceIdController.text,
                    latitude: latitude,
                    longitude: longitude,
                    locationName: nameController.text.isNotEmpty ? nameController.text : null,
                    description: descriptionController.text.isNotEmpty ? descriptionController.text : null,
                  );
                  
                  // Refresh locations
                  _loadDeviceLocations();
                  
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
