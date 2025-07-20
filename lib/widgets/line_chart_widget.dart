// widgets/line_chart_widget.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates on the X-axis

class LineChartWidget extends StatefulWidget {
  final String title;
  final List<FlSpot> data;
  final double minY;
  final double maxY;
  final Color lineColor;
  final bool isSelected;
  final VoidCallback? onTap;
  final String defaultRange;

  const LineChartWidget({
    super.key,
    required this.title,
    required this.data,
    required this.minY,
    required this.maxY,
    required this.lineColor,
    this.isSelected = false,
    this.onTap,
    this.defaultRange = 'Minutes',
  });

  @override
  State<LineChartWidget> createState() => _LineChartWidgetState();
}

class _LineChartWidgetState extends State<LineChartWidget> {
  String _selectedRange = 'Minutes';
  static const List<String> _ranges = [
    'Minutes',
    '5 Minutes',
    'Hours',
    'Days',
    '1 Month',
    '3 Months',
    '4 Months',
    '5 Months',
  ];

  @override
  void initState() {
    super.initState();
    _selectedRange = widget.defaultRange;
  }

  List<FlSpot> getFilteredData() {
    final now = DateTime.now();
    switch (_selectedRange) {
      case 'Minutes':
        return widget.data.where((spot) =>
          DateTime.fromMillisecondsSinceEpoch(spot.x.toInt()).isAfter(now.subtract(const Duration(minutes: 1)))
        ).toList();
      case '5 Minutes':
        return widget.data.where((spot) =>
          DateTime.fromMillisecondsSinceEpoch(spot.x.toInt()).isAfter(now.subtract(const Duration(minutes: 5)))
        ).toList();
      case 'Hours':
        return widget.data.where((spot) =>
          DateTime.fromMillisecondsSinceEpoch(spot.x.toInt()).isAfter(now.subtract(const Duration(hours: 1)))
        ).toList();
      case 'Days':
        return widget.data.where((spot) =>
          DateTime.fromMillisecondsSinceEpoch(spot.x.toInt()).isAfter(now.subtract(const Duration(days: 1)))
        ).toList();
      case '1 Month':
        return widget.data.where((spot) =>
          DateTime.fromMillisecondsSinceEpoch(spot.x.toInt()).isAfter(now.subtract(const Duration(days: 30)))
        ).toList();
      case '3 Months':
        return widget.data.where((spot) =>
          DateTime.fromMillisecondsSinceEpoch(spot.x.toInt()).isAfter(now.subtract(const Duration(days: 90)))
        ).toList();
      case '4 Months':
        return widget.data.where((spot) =>
          DateTime.fromMillisecondsSinceEpoch(spot.x.toInt()).isAfter(now.subtract(const Duration(days: 120)))
        ).toList();
      case '5 Months':
        return widget.data.where((spot) =>
          DateTime.fromMillisecondsSinceEpoch(spot.x.toInt()).isAfter(now.subtract(const Duration(days: 150)))
        ).toList();
      default:
        return widget.data;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredData = getFilteredData();
    final chart = AspectRatio(
      aspectRatio: widget.isSelected ? 1.7 : 1.1,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: false, // Hide all grid lines
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final dateTime = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                  String label;
                  switch (_selectedRange) {
                    case 'Minutes':
                    case '5 Minutes':
                    case 'Hours':
                      label = DateFormat('HH:mm').format(dateTime);
                      break;
                    case 'Days':
                    case '1 Month':
                    case '3 Months':
                    case '4 Months':
                    case '5 Months':
                      label = DateFormat('dd MMM').format(dateTime);
                      break;
                    default:
                      label = DateFormat('HH:mm').format(dateTime);
                  }
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 8.0,
                    child: Text(
                      label,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(0),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: const Color(0xff37434d), width: 1),
          ),
          minX: filteredData.isNotEmpty ? filteredData.first.x : 0,
          maxX: filteredData.isNotEmpty ? filteredData.last.x : 1,
          minY: widget.minY,
          maxY: widget.maxY,
          lineBarsData: [
            LineChartBarData(
              spots: filteredData,
              isCurved: true,
              color: widget.lineColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(
                show: false,
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    widget.lineColor.withOpacity(0.3),
                    widget.lineColor.withOpacity(0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            handleBuiltInTouches: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipRoundedRadius: 8,
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  final spot = barSpot;
                  final dateTime = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                  return LineTooltipItem(
                    '${spot.y.toStringAsFixed(1)}\n${DateFormat('HH:mm').format(dateTime)}',
                    const TextStyle(color: Colors.white),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );

    return GestureDetector(
      onTap: widget.onTap,
      child: Semantics(
        label: '${widget.title} graph',
        child: Tooltip(
          message: 'Graph for ${widget.title}',
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: widget.isSelected ? 400 : 180,
            margin: EdgeInsets.symmetric(horizontal: widget.isSelected ? 12 : 6, vertical: widget.isSelected ? 12 : 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color: widget.lineColor.withOpacity(0.2),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
              border: widget.isSelected ? Border.all(color: widget.lineColor, width: 2) : null,
            ),
            child: Card(
              elevation: widget.isSelected ? 8 : 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedRange,
                              borderRadius: BorderRadius.circular(16),
                              items: _ranges.map((range) => DropdownMenuItem(
                                value: range,
                                child: Text(range),
                              )).toList(),
                              onChanged: (value) {
                                if (value != null) setState(() => _selectedRange = value);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    chart,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
