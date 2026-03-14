import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study_schedule/models/todo.dart';
import 'package:study_schedule/widgets/common/filter_segment.dart';
import 'package:fl_chart/fl_chart.dart';
import "dart:math";

enum Segments {
  achivementRate("Achivement Rate"),
  totalStudyTime("Total Study Time"),
  totalStudyAmount("Total Study Amount"),
  ;

  const Segments(this.displayName);

  final String displayName;

  static List<String> getStringDisplayName() {
    return Segments
      .values
      .map((filter) => filter.displayName)
      .toList();
  }

  static Segments getEnumValueFromString(String name) {
    return Segments.values.firstWhere(
      (v) => v.displayName == name,
      orElse: () => Segments.achivementRate,
    );
  }
}

class StatsChart extends StatefulWidget {
  final List<Todo> todoList;
  const StatsChart({
    super.key,
    required this.todoList
  });

  @override
  State<StatefulWidget> createState() => _StatsChart();
}

class _StatsChart extends State<StatsChart> {
  List<String> segmentsStrList = Segments.getStringDisplayName();
  String selectedFilter = Segments.achivementRate.displayName;
  void onHandleFilter(String newSelection) {
    setState(() {
      selectedFilter = newSelection;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FilterSegment(
          segments: segmentsStrList, 
          currentSelection: selectedFilter, 
          onHandleFilter: onHandleFilter
        ),

        Charts(
          segments: Segments.getEnumValueFromString(selectedFilter),
          todoList: widget.todoList,
        ),

      ],
    );
  }
}

class DailyStats {
  int total = 0;
  int fulfilled = 0;
  int partial = 0;
  int failure = 0;
}

class Charts extends StatelessWidget {
  final Segments segments;
  final List<Todo> todoList;
  
  const Charts({
    super.key,
    required this.segments,
    required this.todoList,
  });

  @override
  Widget build(BuildContext context) {
    switch (segments) {

      case Segments.achivementRate:
        // 1. データの集計（Map<日付, クラス> の形で作る）
        final Map<String, DailyStats> statsMap = {};

        for (var todo in todoList) {
          final dateKey = DateFormat("MM/dd").format(todo.date);
          // 存在しなければ新しいDailyStatsを作成して取得
          final stats = statsMap.putIfAbsent(dateKey, () => DailyStats());

          stats.total++;
          switch (todo.achievement) {
            case Achievement.fulfilled:
              stats.fulfilled++;
              break;
            case Achievement.partial:
              stats.partial++;
              break;
            default:
            // including none and failture case;
              stats.failure++;
              break;
          }
        }

        // グラフ描画用に日付キーのリストを作成
        final dateKeys = statsMap.keys.toList();

        // 2. グラフの描画
        return Padding(
          padding: const EdgeInsets.only(top: 24, right: 16, left: 8),
          child: SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                // Y軸の最大値をタスクの最大数に合わせる
                maxY: _getMaxTotal(statsMap).toDouble() + 1,

                barGroups: List.generate(dateKeys.length, (index) {
                  final dateKey = dateKeys[index];
                  final stats = statsMap[dateKey] ?? DailyStats(); // null安全

                  return BarChartGroupData(
                    x: index, // x軸はint(double)
                    barRods: [
                      BarChartRodData(
                        toY: stats.total.toDouble(),
                        width: 16,
                        // 積み上げの設定
                        rodStackItems: [
                          BarChartRodStackItem(0, stats.failure.toDouble(), Colors.red),
                          BarChartRodStackItem(
                            stats.failure.toDouble(), 
                            (stats.failure + stats.partial).toDouble(), 
                            Colors.orange
                          ),
                          BarChartRodStackItem(
                            (stats.failure + stats.partial).toDouble(), 
                            stats.total.toDouble(), 
                            Colors.green,
                          ),
                        ],
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
                        if (i >= 0 && i < dateKeys.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(dateKeys[i], style: const TextStyle(fontSize: 10)),
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

      case Segments.totalStudyTime:
      case Segments.totalStudyAmount:
        return const Center(child: Text("Coming Soon..."));
    }
  }

  // 最大値を取得するヘルパー関数
  int _getMaxTotal(Map<String, DailyStats> map) {
    if (map.isEmpty) return 5;
    return map.values.map((s) => s.total).reduce(max);
  }
}