import 'package:flutter/material.dart';
import '../models/sensor_data.dart';

class AlertsScreen extends StatelessWidget {
  final List<SensorData> sensorDataList;
  const AlertsScreen({super.key, required this.sensorDataList});

  List<_Alert> _generateAlerts(SensorData data) {
    final List<_Alert> alerts = [];
    // Example thresholds (customize as needed)
    if (data.pHValue < 6.8 || data.pHValue > 8.2) {
      alerts.add(_Alert(
        message: 'pH Value is out of optimal range (6.8 - 8.2)!\nCurrent: ${data.pHValue.toStringAsFixed(2)}',
        level: (data.pHValue < 6.5 || data.pHValue > 8.5) ? AlertLevel.red : AlertLevel.yellow,
      ));
    }
    if (data.dissolvedOxygen < 5.5) {
      alerts.add(_Alert(
        message: 'Dissolved Oxygen is low!\nCurrent: ${data.dissolvedOxygen.toStringAsFixed(2)} mg/L',
        level: data.dissolvedOxygen < 4.5 ? AlertLevel.red : AlertLevel.yellow,
      ));
    }
    if (data.waterTemperature < 22 || data.waterTemperature > 28) {
      alerts.add(_Alert(
        message: 'Water Temperature is out of optimal range (22-28°C)!\nCurrent: ${data.waterTemperature.toStringAsFixed(2)}°C',
        level: (data.waterTemperature < 20 || data.waterTemperature > 30) ? AlertLevel.red : AlertLevel.yellow,
      ));
    }
    if (data.tdsWater > 250) {
      alerts.add(_Alert(
        message: 'TDS of Water is high!\nCurrent: ${data.tdsWater.toStringAsFixed(0)} ppm',
        level: data.tdsWater > 300 ? AlertLevel.red : AlertLevel.yellow,
      ));
    }
    if (data.airTemperature < 20 || data.airTemperature > 35) {
      alerts.add(_Alert(
        message: 'Air Temperature is out of optimal range (20-35°C)!\nCurrent: ${data.airTemperature.toStringAsFixed(2)}°C',
        level: (data.airTemperature < 15 || data.airTemperature > 40) ? AlertLevel.red : AlertLevel.yellow,
      ));
    }
    if (data.airHumidity < 60 || data.airHumidity > 90) {
      alerts.add(_Alert(
        message: 'Air Humidity is out of optimal range (60-90%)!\nCurrent: ${data.airHumidity.toStringAsFixed(2)}%',
        level: (data.airHumidity < 50 || data.airHumidity > 95) ? AlertLevel.red : AlertLevel.yellow,
      ));
    }
    if (alerts.isEmpty) {
      alerts.add(_Alert(
        message: 'All parameters are within optimal range.',
        level: AlertLevel.green,
      ));
    }
    return alerts;
  }

  @override
  Widget build(BuildContext context) {
    final SensorData latest = sensorDataList.isNotEmpty ? sensorDataList.last : SensorData.mock();
    final alerts = _generateAlerts(latest);
    return Scaffold(
      appBar: AppBar(title: const Text('Alerts')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: alerts.length,
        itemBuilder: (context, i) {
          final alert = alerts[i];
          return Card(
            color: alert.level == AlertLevel.red
                ? Colors.red[100]
                : alert.level == AlertLevel.yellow
                    ? Colors.yellow[100]
                    : Colors.green[100],
            child: ListTile(
              leading: Icon(
                alert.level == AlertLevel.red
                    ? Icons.error
                    : alert.level == AlertLevel.yellow
                        ? Icons.warning
                        : Icons.check_circle,
                color: alert.level == AlertLevel.red
                    ? Colors.red
                    : alert.level == AlertLevel.yellow
                        ? Colors.orange
                        : Colors.green,
              ),
              title: Text(alert.message),
            ),
          );
        },
      ),
    );
  }
}

enum AlertLevel { green, yellow, red }

class _Alert {
  final String message;
  final AlertLevel level;
  _Alert({required this.message, required this.level});
}
