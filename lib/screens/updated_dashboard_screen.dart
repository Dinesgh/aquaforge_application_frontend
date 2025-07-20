// screens/updated_dashboard_screen.dart
import 'package:flutter/material.dart';
import '../models/sensor_data.dart';
import '../services/data_service.dart';
import '../services/prediction_service.dart';
import '../services/backend_auth_client.dart';
import '../widgets/sensor_card.dart';
import '../widgets/line_chart_widget.dart';
import '../widgets/module_row.dart';
import '../widgets/aquaforge_header.dart';
import 'package:fl_chart/fl_chart.dart';

class UpdatedDashboardScreen extends StatefulWidget {
  const UpdatedDashboardScreen({super.key});

  @override
  State<UpdatedDashboardScreen> createState() => _UpdatedDashboardScreenState();
}

class _UpdatedDashboardScreenState extends State<UpdatedDashboardScreen> with SingleTickerProviderStateMixin {
  late Future<List<SensorData>> _sensorDataFuture;
  final DataService _dataService = DataService();
  final BackendAuthClient _authClient = BackendAuthClient();
  
  SensorData? _currentSensorData;
  late AnimationController _animationController;
  String _selectedModule = 'Dashboards';
  String _selectedSensor = 'pH Value';
  String _selectedGraph = 'pH Value';
  String? _prediction;
  final PredictionService _predictionService = PredictionService(apiUrl: 'https://your-ai-api-url');

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // Verify authentication status before loading data
    _checkAuthAndLoadData();
  }
  
  Future<void> _checkAuthAndLoadData() async {
    // Check if user is authenticated using our backend client
    final isAuthenticated = await _authClient.isAuthenticated();
    
    if (!isAuthenticated) {
      if (mounted) {
        // If not authenticated, redirect to login
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }
    }
    
    // If we're still here (authenticated), load data
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _sensorDataFuture = _dataService.fetchSensorData();
    });
    _sensorDataFuture.then((data) async {
      if (data.isNotEmpty) {
        setState(() {
          _currentSensorData = data.last;
        });
        _animationController.forward(from: 0.0);
        // Fetch AI prediction
        try {
          final prediction = await _predictionService.getPrediction(data.last);
          setState(() {
            _prediction = prediction;
          });
        } catch (e) {
          setState(() {
            _prediction = 'Prediction error';
          });
        }
      }
    });
  }

  void _onModuleTap(String module) {
    setState(() {
      _selectedModule = module;
    });
    if (module == 'AI Analysis') {
      Navigator.pushNamed(context, '/ai-analysis');
    } else if (module == 'Configuration') {
      Navigator.pushNamed(context, '/configuration');
    } else if (module == 'Devices') {
      Navigator.pushNamed(context, '/devices');
    }
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    
    if (shouldLogout == true) {
      await _authClient.logout();
      
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: const AquaForgeHeader(),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Data',
            onPressed: _fetchData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchData,
        backgroundColor: theme.primaryColor,
        child: const Icon(Icons.refresh),
        tooltip: 'Refresh',
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: FutureBuilder<List<SensorData>>(
          future: _sensorDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: [${snapshot.error}]'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No sensor data available.'));
            } else {
              final List<SensorData> sensorDataList = snapshot.data!;
              _currentSensorData = sensorDataList.last;
              _animationController.forward(from: 0.0);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Module Row
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      margin: const EdgeInsets.only(bottom: 24),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        child: ModuleRow(
                          selectedModule: _selectedModule,
                          onModuleTap: _onModuleTap,
                        ),
                      ),
                    ),
                    
                    // Rest of the dashboard UI...
                    // (Same as your current dashboard implementation)
                    
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
