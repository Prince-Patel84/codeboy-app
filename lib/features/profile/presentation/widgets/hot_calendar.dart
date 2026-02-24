import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

class HotCalendar extends StatelessWidget {
  final Map<String, dynamic> heatmapData;

  const HotCalendar({super.key, required this.heatmapData});

  @override
  Widget build(BuildContext context) {
    // Parse the heatmap data (which is {'YYYY-MM-DD': count})
    Map<DateTime, int> datasets = {};
    heatmapData.forEach((key, value) {
      if (key.isNotEmpty) {
        try {
          DateTime date = DateTime.parse(key);
          datasets[date] = (value as num).toInt();
        } catch (_) {}
      }
    });

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Recent Activity",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            HeatMap(
              datasets: datasets,
              colorMode: ColorMode.opacity,
              showText: false,
              scrollable: true,
              size: 20,
              colorsets: {
                1: isDark ? Colors.blueAccent : Colors.blue,
              },
              textColor: isDark ? Colors.white70 : Colors.black87,
            ),
          ],
        ),
      ),
    );
  }
}
