import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StatsStackBarChart extends StatelessWidget {
  // barValues must not be incremental values.
  // It should be distinct values you want to put vertically.
  final double maxValue;
  final List<dynamic> keys;
  final Map<String, List<double>> barValues;
  final List<Color> colors;

  const StatsStackBarChart({
    super.key,
    required this.maxValue,
    required this.keys,
    required this.barValues,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, right: 16, left: 8),
      child: SizedBox(
        height: 300,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            // Y軸の最大値をタスクの最大数に合わせる
            maxY: maxValue,

            barGroups: List.generate(keys.length, (index) {
              final key = keys[index];
              final stats = barValues[key] ?? [];
              final List<double> barStats = [0];

              for(var i = 0; i < stats.length; i++) {
                final addValue = barStats[i] + stats[i];
                barStats.add(addValue);
              }

              final total = stats.isEmpty ? 0.0 : stats.reduce((a, b) => a + b);

              return BarChartGroupData(
                x: index, // x軸はint(double)
                barRods: [
                  BarChartRodData(
                    toY: total,
                    width: 16,
                    // 積み上げの設定
                    rodStackItems: [ for(var i = 0; i < barStats.length - 1; i++) BarChartRodStackItem(barStats[i], barStats[i+1], colors[i]) ],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ],
              );
            }),

            // 軸ラベルやグリッドの設定
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    int i = value.toInt();
                    if (i >= 0 && i < keys.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(keys[i], style: const TextStyle(fontSize: 10)),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
          ),
        ),
      ),
    );
  }
}