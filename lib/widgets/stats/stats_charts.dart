
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study_schedule/models/todo.dart';
import 'package:study_schedule/widgets/stats/stats_chart_area.dart';
import 'package:study_schedule/widgets/stats/stats_lin_chart.dart';
import 'package:study_schedule/widgets/stats/stats_stack_bar_chart.dart';

class DailyStats {
  int total = 0;
  int fulfilled = 0;
  int partial = 0;
  int failure = 0;

  List<double> toSegmentValueList() {
    return [failure.toDouble(), partial.toDouble(), fulfilled.toDouble()];
  }
}

class StatsCharts extends StatelessWidget {
  final Segments segments;
  final List<Todo> todoList;
  
  const StatsCharts({
    super.key,
    required this.segments,
    required this.todoList,
  });

  @override
  Widget build(BuildContext context) {
    switch (segments) {

      case Segments.achivementRate:
        final Map<String, DailyStats> statsMap = {};

        for (var todo in todoList) {
          final dateKey = DateFormat("MM/dd").format(todo.date);

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

        final dateKeys = statsMap.keys.toList();

        return StatsStackBarChart(
          maxValue: _getMaxTotal(statsMap).toDouble(), 
          keys: dateKeys, 
          barValues: { for(var val in statsMap.entries) val.key: val.value.toSegmentValueList() }, 
          colors: [Colors.red, Colors.orange, Colors.green],
        );

      case Segments.totalStudyTime:
        final Map<String, double> statsMap = {};
        for (var todo in todoList) {
          final dateKey = DateFormat("MM/dd").format(todo.date);
          final actualStudyTime = todo.actualStudyTime;
          if(actualStudyTime != null) {
            statsMap[dateKey] = (statsMap[dateKey] ?? 0) + actualStudyTime.toDouble() ;
          }
        }

        return StatsLinChart(
          color: Colors.blue, 
          statsMap: statsMap
        );

      case Segments.totalStudyAmount:
        final Map<String, double> statsMap = {};
        for (var todo in todoList) {
          final dateKey = DateFormat("MM/dd").format(todo.date);
          final actualStudyAmount = todo.actualStudyAmount;
          if(actualStudyAmount != null) {
            statsMap[dateKey] = (statsMap[dateKey] ?? 0) + actualStudyAmount.toDouble() ;
          }
        }

        return StatsLinChart(
          color: Colors.blue, 
          statsMap: statsMap
        );
    }
  }

  // 最大値を取得するヘルパー関数
  int _getMaxTotal(Map<String, DailyStats> map) {
    if (map.isEmpty) return 5;
    return map.values.map((s) => s.total).reduce(max);
  }
}