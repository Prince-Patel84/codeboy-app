import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SpiderDiagram extends StatefulWidget {
  final Map<String, dynamic> ratingMatrix;
  final String currentRating;

  const SpiderDiagram({
    super.key,
    required this.ratingMatrix,
    required this.currentRating,
  });

  @override
  State<SpiderDiagram> createState() => _SpiderDiagramState();
}

class _SpiderDiagramState extends State<SpiderDiagram> {
  String? _selectedRating;

  @override
  void initState() {
    super.initState();
    if (widget.ratingMatrix.isNotEmpty) {
      // Try to select the user's current rating level, or just the first key if unrated
      if (widget.ratingMatrix.containsKey(widget.currentRating)) {
        _selectedRating = widget.currentRating;
      } else {
        _selectedRating = widget.ratingMatrix.keys.first;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.ratingMatrix.isEmpty) {
      return const Card(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: Text("No proficiency data available yet.")),
        ),
      );
    }

    // Prepare data for the selected rating level
    Map<String, dynamic> topicsRaw = widget.ratingMatrix[_selectedRating] ?? {};
    
    // Sort and take top 8 topics to prevent overcrowding the spider chart
    var sortedTopics = topicsRaw.entries.toList()
      ..sort((a, b) => (b.value as num).compareTo(a.value as num));
    
    // Fallback if empty
    if (sortedTopics.isEmpty) {
      sortedTopics = [const MapEntry('None', 1)];
    } else if (sortedTopics.length > 8) {
      sortedTopics = sortedTopics.take(8).toList();
    }
    
    // fl_chart RadarChart requires at least 3 features or it throws an assertion error
    while (sortedTopics.length < 3) {
      sortedTopics.add(const MapEntry('', 0.1));
    }

    // Find max value to scale the chart
    double maxValue = 5.0; // minimum scale
    for (var entry in sortedTopics) {
      if ((entry.value as num).toDouble() > maxValue) {
        maxValue = (entry.value as num).toDouble();
      }
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Topic Proficiency",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  value: _selectedRating,
                  items: widget.ratingMatrix.keys.map((String ratingKey) {
                    return DropdownMenuItem<String>(
                      value: ratingKey,
                      child: Text("Rating: $ratingKey"),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedRating = val;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: RadarChart(
                RadarChartData(
                  tickCount: 3,
                  ticksTextStyle: const TextStyle(color: Colors.transparent),
                  titleTextStyle: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  radarBorderData: const BorderSide(color: Colors.grey, width: 1.5),
                  gridBorderData: const BorderSide(color: Colors.grey, width: 1),
                  radarShape: RadarShape.polygon,
                  titlePositionPercentageOffset: 0.1,
                  dataSets: [
                    RadarDataSet(
                      fillColor: primaryColor.withValues(alpha: 0.4),
                      borderColor: primaryColor,
                      entryRadius: 3,
                      dataEntries: sortedTopics.map((e) => RadarEntry(value: (e.value as num).toDouble())).toList(),
                      borderWidth: 2,
                    ),
                  ],
                  getTitle: (index, angle) {
                    // Extracting the topic name
                    if (index < sortedTopics.length) {
                      String text = sortedTopics[index].key;
                      // truncated for display
                      if(text.length > 10) text = "${text.substring(0, 8)}..";
                      return RadarChartTitle(text: text, angle: 0); // No angle, read naturally Let fl_chart handle position
                    }
                    return const RadarChartTitle(text: "");
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Progressive Overload Target Map for $_selectedRating",
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white54 : Colors.black54,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
