import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StatsLinChart extends StatelessWidget {
  final Color color;
  final Map<String, double> statsMap;
  const StatsLinChart({
    super.key,
    required this.color,
    required this.statsMap,
  });

  @override
  Widget build(BuildContext context) {
    final keys = statsMap.keys.toList();

    return Padding(
      padding: const EdgeInsets.only(top: 24, right: 16, left: 8),
      child: SizedBox(
        height: 300,
        child: LineChart(
          LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: List.generate(keys.length, (index) {
                  final key = keys[index];
                  final stat = statsMap[key] ?? 0;
                  return FlSpot(index.toDouble(), stat);

                }),
                isCurved: true,
                barWidth: 3,
                color: color,
                belowBarData: BarAreaData(
                  show: true,
                  color: color.withValues(alpha: 0.2),
                ),
                dotData: const FlDotData(show: true),
              )
            ],
            titlesData: FlTitlesData(
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (val, _) {
                    final index = val.toInt();
                    // 範囲外アクセスを防ぐガード
                    if (index < 0 || index >= keys.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(keys[index], style: const TextStyle(fontSize: 10)),
                    );
                  }
                )
              )
            )
          ),
        )
      )
    );
  }
}