// screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import '../models/sensor_data.dart';
import '../services/data_service.dart';
import '../services/prediction_service.dart';
import '../services/auth_helper.dart';
import '../widgets/sensor_card.dart';
import '../widgets/line_chart_widget.dart';
import '../widgets/module_row.dart'; // Importing ModuleRow widget
import '../widgets/aquaforge_header.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  Future<List<SensorData>>? _sensorDataFuture; // Changed from late to nullable
  final DataService _dataService = DataService();
  SensorData? _currentSensorData;
  late AnimationController _animationController;
  String _selectedModule = 'Dashboards';
  String _selectedSensor = 'pH Value'; // State to track the selected sensor
  String _selectedGraph = 'pH Value';
  String? _prediction;
  final PredictionService _predictionService = PredictionService(apiUrl: 'https://your-ai-api-url'); // Set your API URL

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
    // Check if user is authenticated
    await AuthHelper.ensureAuthenticated(context);
    
    // If we're still here (not redirected), load data
    _fetchData();
    
    // Get user data to personalize the experience
    final authHelper = AuthHelper();
    final userData = await authHelper.getUserData();
    if (userData != null) {
      debugPrint('Dashboard loaded for user: ${userData['username']}');
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      _sensorDataFuture = _dataService.fetchSensorData();
    });
    _sensorDataFuture?.then((data) async {
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
      // Prevent duplicate navigation by checking current route
      if (ModalRoute.of(context)?.settings.name != '/ai-analysis') {
        Navigator.pushNamed(context, '/ai-analysis');
      }
    } else if (module == 'Configuration') {
      // Navigate to configuration screen
      if (ModalRoute.of(context)?.settings.name != '/configuration') {
        Navigator.pushNamed(context, '/configuration');
      }
    } else if (module == 'Location') {
      // Navigate to device map screen
      if (ModalRoute.of(context)?.settings.name != '/device-map') {
        Navigator.pushNamed(context, '/device-map');
      }
    }
    // You can add more navigation logic for other modules if needed
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
      backgroundColor: const Color(0xFFF6F8FB), // Subtle background
      appBar: AppBar(
        title: const AquaForgeHeader(),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        automaticallyImplyLeading: false, // Remove back button
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Data',
            onPressed: _fetchData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              // Show confirmation dialog
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
              
              // If user confirmed logout
              if (shouldLogout == true) {
                final authHelper = AuthHelper();
                await authHelper.logout();
                
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                }
              }
            },
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
          future: _sensorDataFuture ?? Future.value([]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: [${snapshot.error}'));
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
                    // Current Readings Section
                    Row(
                      children: [
                        Icon(Icons.sensors, color: theme.primaryColor),
                        const SizedBox(width: 8),
                        const Text(
                          'Current Readings',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              ...[
                                {
                                  'title': 'pH Value',
                                  'value': _currentSensorData!.pHValue.toStringAsFixed(1),
                                  'unit': '',
                                  'icon': Icons.science,
                                  'color': const Color.fromARGB(255, 16, 72, 170),
                                },
                                {
                                  'title': 'Dissolved Oxygen',
                                  'value': _currentSensorData!.dissolvedOxygen.toStringAsFixed(1),
                                  'unit': 'mg/L',
                                  'icon': Icons.bubble_chart,
                                  'color': const Color.fromARGB(255, 216, 67, 13),
                                },
                                {
                                  'title': 'Water Temperature',
                                  'value': _currentSensorData!.waterTemperature.toStringAsFixed(1),
                                  'unit': '°C',
                                  'icon': Icons.thermostat,
                                  'color': Colors.orangeAccent,
                                },
                                {
                                  'title': 'TDS of Water',
                                  'value': _currentSensorData!.tdsWater.toStringAsFixed(0),
                                  'unit': 'ppm',
                                  'icon': Icons.opacity,
                                  'color': const Color.fromARGB(255, 22, 165, 56),
                                },
                                {
                                  'title': 'Air Temperature',
                                  'value': _currentSensorData!.airTemperature.toStringAsFixed(1),
                                  'unit': '°C',
                                  'icon': Icons.thermostat_outlined,
                                  'color': const Color.fromARGB(255, 243, 3, 3),
                                },
                                {
                                  'title': 'Air Humidity',
                                  'value': _currentSensorData!.airHumidity.toStringAsFixed(1),
                                  'unit': '%',
                                  'icon': Icons.water,
                                  'color': const Color.fromARGB(255, 80, 199, 171),
                                },
                              ].map((sensor) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: SensorCard(
                                  title: sensor['title'] as String,
                                  value: sensor['value'] as String,
                                  unit: sensor['unit'] as String,
                                  icon: sensor['icon'] as IconData,
                                  color: sensor['color'] as Color,
                                  isSelected: _selectedSensor == sensor['title'],
                                  onTap: () {
                                    setState(() {
                                      _selectedSensor = sensor['title'] as String;
                                      _selectedGraph = sensor['title'] as String;
                                    });
                                  },
                                ),
                              )).toList(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Graphs Section
                    Row(
                      children: [
                        Icon(Icons.show_chart, color: theme.primaryColor),
                        const SizedBox(width: 8),
                        const Text(
                          'Sensor Trends',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: LineChartWidget(
                                    title: 'pH Value',
                                    data: sensorDataList.map((data) => FlSpot(data.timestamp.millisecondsSinceEpoch.toDouble(), data.pHValue)).toList(),
                                    minY: 0,
                                    maxY: 14,
                                    lineColor: Colors.blue,
                                    isSelected: _selectedGraph == 'pH Value',
                                    onTap: () {
                                      setState(() {
                                        _selectedGraph = _selectedGraph == 'pH Value' ? '' : 'pH Value';
                                      });
                                    },
                                    defaultRange: 'Hours',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: LineChartWidget(
                                    title: 'Dissolved Oxygen',
                                    data: sensorDataList.map((data) => FlSpot(data.timestamp.millisecondsSinceEpoch.toDouble(), data.dissolvedOxygen)).toList(),
                                    minY: 0,
                                    maxY: 10,
                                    lineColor: Colors.green,
                                    isSelected: _selectedGraph == 'Dissolved Oxygen',
                                    onTap: () {
                                      setState(() {
                                        _selectedGraph = _selectedGraph == 'Dissolved Oxygen' ? '' : 'Dissolved Oxygen';
                                      });
                                    },
                                    defaultRange: 'Hours',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: LineChartWidget(
                                    title: 'Water Temperature',
                                    data: sensorDataList.map((data) => FlSpot(data.timestamp.millisecondsSinceEpoch.toDouble(), data.waterTemperature)).toList(),
                                    minY: 0,
                                    maxY: 40,
                                    lineColor: Colors.orange,
                                    isSelected: _selectedGraph == 'Water Temperature',
                                    onTap: () {
                                      setState(() {
                                        _selectedGraph = _selectedGraph == 'Water Temperature' ? '' : 'Water Temperature';
                                      });
                                    },
                                    defaultRange: 'Hours',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: LineChartWidget(
                                    title: 'TDS of Water',
                                    data: sensorDataList.map((data) => FlSpot(data.timestamp.millisecondsSinceEpoch.toDouble(), data.tdsWater)).toList(),
                                    minY: 0,
                                    maxY: 500,
                                    lineColor: Colors.purple,
                                    isSelected: _selectedGraph == 'TDS of Water',
                                    onTap: () {
                                      setState(() {
                                        _selectedGraph = _selectedGraph == 'TDS of Water' ? '' : 'TDS of Water';
                                      });
                                    },
                                    defaultRange: 'Hours',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: LineChartWidget(
                                    title: 'Air Temperature',
                                    data: sensorDataList.map((data) => FlSpot(data.timestamp.millisecondsSinceEpoch.toDouble(), data.airTemperature)).toList(),
                                    minY: 0,
                                    maxY: 50,
                                    lineColor: Colors.red,
                                    isSelected: _selectedGraph == 'Air Temperature',
                                    onTap: () {
                                      setState(() {
                                        _selectedGraph = _selectedGraph == 'Air Temperature' ? '' : 'Air Temperature';
                                      });
                                    },
                                    defaultRange: 'Hours',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: LineChartWidget(
                                    title: 'Air Humidity',
                                    data: sensorDataList.map((data) => FlSpot(data.timestamp.millisecondsSinceEpoch.toDouble(), data.airHumidity)).toList(),
                                    minY: 0,
                                    maxY: 100,
                                    lineColor: Colors.teal,
                                    isSelected: _selectedGraph == 'Air Humidity',
                                    onTap: () {
                                      setState(() {
                                        _selectedGraph = _selectedGraph == 'Air Humidity' ? '' : 'Air Humidity';
                                      });
                                    },
                                    defaultRange: 'Hours',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
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
