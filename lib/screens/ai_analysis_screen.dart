import 'package:flutter/material.dart';
import 'dart:ui';

class AIAnalysisScreen extends StatefulWidget {
  const AIAnalysisScreen({super.key});

  @override
  State<AIAnalysisScreen> createState() => _AIAnalysisScreenState();
}

class _AIAnalysisScreenState extends State<AIAnalysisScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Map<String, dynamic> _demoData;
  late String _demoPrediction;

  late String _selectedBreed = 'Vannamei';
  late String _selectedFeed = 'CP Feed';
  late String _shrimpAge = '';

  final List<String> _breeds = ['Vannamei', 'Monodon', 'Other'];
  final List<String> _feeds = ['CP Feed', 'Avanti Feed', 'Godrej Feed', 'Other'];

  // Animation for input fields
  late Animation<Offset> _breedOffsetAnim;
  late Animation<Offset> _feedOffsetAnim;
  late Animation<Offset> _ageOffsetAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _breedOffsetAnim = Tween<Offset>(begin: const Offset(-0.5, 0), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)));
    _feedOffsetAnim = Tween<Offset>(begin: const Offset(0.0, 0.5), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.7, curve: Curves.easeOut)));
    _ageOffsetAnim = Tween<Offset>(begin: const Offset(0.5, 0), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.9, curve: Curves.easeOut)));
    _controller.forward();
    // Demo data
    _demoPrediction = 'High Risk: Water quality parameters indicate a potential issue.';
    _demoData = {
      'pH Value': '8.4 (High)',
      'Dissolved Oxygen': '4.2 mg/L (Low)',
      'Water Temperature': '29.5°C (Slightly High)',
      'TDS of Water': '210 ppm (Normal)',
      'Air Temperature': '32.0°C (Normal)',
      'Air Humidity': '88% (Normal)',
      'AI Recommendation': 'Increase aeration and monitor pH levels closely.'
    };
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Analysis')),
      body: FadeTransition(
        opacity: _fadeIn,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // User input section with animation and row layout
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.only(bottom: 24),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 600;
                    return isWide
                        ? Row(
                            children: [
                              Expanded(
                                child: SlideTransition(
                                  position: _breedOffsetAnim,
                                  child: _buildBreedField(),
                                ),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: SlideTransition(
                                  position: _feedOffsetAnim,
                                  child: _buildFeedField(),
                                ),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: SlideTransition(
                                  position: _ageOffsetAnim,
                                  child: _buildAgeField(),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              SlideTransition(
                                position: _breedOffsetAnim,
                                child: _buildBreedField(),
                              ),
                              const SizedBox(height: 16),
                              SlideTransition(
                                position: _feedOffsetAnim,
                                child: _buildFeedField(),
                              ),
                              const SizedBox(height: 16),
                              SlideTransition(
                                position: _ageOffsetAnim,
                                child: _buildAgeField(),
                              ),
                            ],
                          );
                  },
                ),
              ),
            ),
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              color: Colors.indigo[50],
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.indigo, size: 40),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('AI Prediction', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(_demoPrediction, style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Animated Pond Landscape with Sensor Readings
            SizedBox(
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Pond landscape background
                  Positioned.fill(
                    child: AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 800),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFB3E5FC), Color(0xFF0288D1)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: CustomPaint(
                          painter: _PondPainter(),
                        ),
                      ),
                    ),
                  ),
                  // Animated sensor readings
                  ..._buildAnimatedSensorReadings(),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text('Detailed Analysis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._demoData.entries.map((entry) => AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final delay = _demoData.keys.toList().indexOf(entry.key) * 0.1;
                final show = _controller.value > delay;
                return AnimatedOpacity(
                  opacity: show ? 1 : 0,
                  duration: const Duration(milliseconds: 400),
                  child: show
                      ? Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          child: ListTile(
                            leading: Icon(Icons.analytics, color: Colors.indigo[300]),
                            title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(entry.value.toString()),
                          ),
                        )
                      : const SizedBox.shrink(),
                );
              },
            )),
          ],
        ),
      ),
    );
  }

  // Helper widgets for input fields
  int _focusedIndex = -1;

  Widget _animatedInputCard({
    required int index,
    required Color color,
    required IconData icon,
    required String label,
    required Widget child,
  }) {
    final isFocused = _focusedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _focusedIndex = index;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            width: 2.5,
            color: isFocused ? color.withOpacity(0.7) : color.withOpacity(0.25),
            style: BorderStyle.solid,
          ),
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.18),
              Colors.white.withOpacity(0.12),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(isFocused ? 0.22 : 0.10),
              blurRadius: isFocused ? 32 : 16,
              spreadRadius: 1,
              offset: const Offset(0, 8),
            ),
          ],
          backgroundBlendMode: BlendMode.overlay,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: color, size: 32),
                      const SizedBox(width: 12),
                      Text(
                        label,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: color.withOpacity(0.85),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBreedField() {
    return _animatedInputCard(
      index: 0,
      color: Colors.indigo,
      icon: Icons.bug_report,
      label: 'Breed of Shrimp',
      child: DropdownButtonFormField<String>(
        value: _selectedBreed,
        decoration: const InputDecoration(
          hintText: 'Select breed',
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
          filled: true,
          fillColor: Colors.transparent,
        ),
        items: _breeds.map((breed) => DropdownMenuItem(
          value: breed,
          child: Text(breed),
        )).toList(),
        onChanged: (val) {
          setState(() {
            _selectedBreed = val!;
            _focusedIndex = 0;
          });
        },
        onTap: () {
          setState(() {
            _focusedIndex = 0;
          });
        },
      ),
    );
  }

  Widget _buildFeedField() {
    return _animatedInputCard(
      index: 1,
      color: Colors.green,
      icon: Icons.rice_bowl,
      label: 'Type of Feed',
      child: DropdownButtonFormField<String>(
        value: _selectedFeed,
        decoration: const InputDecoration(
          hintText: 'Select feed',
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
          filled: true,
          fillColor: Colors.transparent,
        ),
        items: _feeds.map((feed) => DropdownMenuItem(
          value: feed,
          child: Text(feed),
        )).toList(),
        onChanged: (val) {
          setState(() {
            _selectedFeed = val!;
            _focusedIndex = 1;
          });
        },
        onTap: () {
          setState(() {
            _focusedIndex = 1;
          });
        },
      ),
    );
  }

  Widget _buildAgeField() {
    return _animatedInputCard(
      index: 2,
      color: Colors.orange,
      icon: Icons.cake,
      label: 'Age of Shrimp (days)',
      child: TextFormField(
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          hintText: 'Enter age in days',
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
          filled: true,
          fillColor: Colors.transparent,
        ),
        onTap: () {
          setState(() {
            _focusedIndex = 2;
          });
        },
        onChanged: (val) {
          setState(() {
            _shrimpAge = val;
            _focusedIndex = 2;
          });
        },
      ),
    );
  }

  // Helper: Animated sensor readings positioned on the pond
  List<Widget> _buildAnimatedSensorReadings() {
    final sensors = [
      {
        'label': 'pH',
        'value': _demoData['pH Value'],
        'icon': Icons.science,
        'top': 40.0,
        'left': 60.0,
        'color': Colors.green[400],
      },
      {
        'label': 'DO',
        'value': _demoData['Dissolved Oxygen'],
        'icon': Icons.water_drop,
        'top': 120.0,
        'left': 120.0,
        'color': Colors.blue[400],
      },
      {
        'label': 'Temp',
        'value': _demoData['Water Temperature'],
        'icon': Icons.thermostat,
        'top': 80.0,
        'left': 220.0,
        'color': Colors.orange[400],
      },
      {
        'label': 'TDS',
        'value': _demoData['TDS of Water'],
        'icon': Icons.opacity,
        'top': 160.0,
        'left': 180.0,
        'color': Colors.purple[400],
      },
      {
        'label': 'Air Temp',
        'value': _demoData['Air Temperature'],
        'icon': Icons.cloud,
        'top': 30.0,
        'left': 280.0,
        'color': Colors.red[400],
      },
      {
        'label': 'Humidity',
        'value': _demoData['Air Humidity'],
        'icon': Icons.air,
        'top': 170.0,
        'left': 300.0,
        'color': Colors.teal[400],
      },
    ];
    return List.generate(sensors.length, (i) {
      final s = sensors[i];
      return AnimatedPositioned(
        duration: Duration(milliseconds: 700 + i * 120),
        curve: Curves.easeOutBack,
        top: s['top'] as double,
        left: s['left'] as double,
        child: _SensorBubble(
          label: s['label'] as String,
          value: s['value'] as String?,
          icon: s['icon'] as IconData,
          color: s['color'] as Color?,
        ),
      );
    });
  }
}

// Custom painter for pond landscape
class _PondPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pondPaint = Paint()
      ..shader = LinearGradient(
        colors: [const Color(0xFF4FC3F7), const Color(0xFF0288D1)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    final pondRect = Rect.fromLTWH(30, 40, size.width - 60, size.height - 80);
    canvas.drawOval(pondRect, pondPaint);
    // Add some ripples
    final ripplePaint = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (int i = 0; i < 3; i++) {
      canvas.drawOval(
        Rect.fromCenter(
          center: pondRect.center,
          width: pondRect.width * (0.7 + i * 0.15),
          height: pondRect.height * (0.7 + i * 0.15),
        ),
        ripplePaint,
      );
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Widget for sensor bubble
class _SensorBubble extends StatelessWidget {
  final String label;
  final String? value;
  final IconData icon;
  final Color? color;
  const _SensorBubble({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
          AnimatedScale(
            scale: 1.0,
            duration: const Duration(milliseconds: 600),
            child: CircleAvatar(
              backgroundColor: color?.withOpacity(0.85) ?? Colors.blue,
              radius: 22,
              child: Icon(icon, color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          if (value != null)
            Text(value!, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
