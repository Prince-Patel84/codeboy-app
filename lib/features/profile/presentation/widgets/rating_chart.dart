import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:dio/dio.dart';

class RatingChart extends StatefulWidget {
  final String handle;

  const RatingChart({super.key, required this.handle});

  @override
  State<RatingChart> createState() => _RatingChartState();
}

class _RatingChartState extends State<RatingChart> {
  List<FlSpot> _spots = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRatingHistory();
  }

  Future<void> _fetchRatingHistory() async {
    try {
      final response = await Dio().get('https://codeforces.com/api/user.rating?handle=${widget.handle}');
      if (response.data['status'] == 'OK') {
        final List<dynamic> result = response.data['result'];
        if (result.isNotEmpty) {
          final spots = <FlSpot>[];
          for (int i = 0; i < result.length; i++) {
            // x = index, y = newRating
            spots.add(FlSpot(i.toDouble(), (result[i]['newRating'] as num).toDouble()));
          }
          setState(() {
            _spots = spots;
            _isLoading = false;
          });
          return;
        }
      }
    } catch (_) {}
    
    // Fallback if failed or no history
    setState(() {
      _spots = [const FlSpot(0, 0)];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_spots.length <= 1) {
      return const SizedBox.shrink(); // Need at least 2 points to draw a meaningful line chart
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Find min and max Y for better scaling
    double minY = _spots.first.y;
    double maxY = _spots.first.y;
    for (var s in _spots) {
      if (s.y < minY) minY = s.y;
      if (s.y > maxY) maxY = s.y;
    }
    
    minY = minY - 100 < 0 ? 0 : minY - 100;
    maxY = maxY + 100;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Rating History",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  minY: minY,
                  maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _spots,
                      isCurved: true,
                      color: Theme.of(context).primaryColor,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black87,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 200,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Theme.of(context).dividerColor,
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
