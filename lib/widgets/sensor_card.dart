// widgets/sensor_card.dart
import 'package:flutter/material.dart';

class SensorCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool isSelected;

  const SensorCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    this.onTap,
    this.isSelected = false,
  });

  static Color getColorByValue(String title, double value) {
    switch (title) {
      case 'pH Value':
        if (value >= 6.5 && value <= 8.5) return Colors.green;
        if (value < 6.5) return Colors.orange;
        return Colors.red;
      case 'Dissolved Oxygen':
        if (value >= 5.0) return Colors.green;
        if (value >= 3.0) return Colors.orange;
        return Colors.red;
      case 'Water Temperature':
        if (value >= 20 && value <= 28) return Colors.green;
        if (value < 20) return Colors.orange;
        return Colors.red;
      case 'TDS of Water':
        if (value <= 250) return Colors.green;
        if (value <= 350) return Colors.orange;
        return Colors.red;
      case 'Air Temperature':
        if (value >= 20 && value <= 35) return Colors.green;
        if (value < 20) return Colors.orange;
        return Colors.red;
      case 'Air Humidity':
        if (value >= 60 && value <= 90) return Colors.green;
        if (value < 60) return Colors.orange;
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title: $value $unit',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Tooltip(
          message: '$title: $value $unit',
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: Card(
              elevation: isSelected ? 16 : 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
                side: isSelected
                    ? BorderSide(color: color, width: 2)
                    : BorderSide.none,
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.8), color.withOpacity(1.0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        icon,
                        size: 40,
                        color: Colors.white.withOpacity(0.9),
                        semanticLabel: title,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 5),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '$value $unit',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}