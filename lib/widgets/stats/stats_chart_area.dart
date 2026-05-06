import 'package:flutter/material.dart';
import 'package:study_schedule/models/todo.dart';
import 'package:study_schedule/widgets/common/filter_segment.dart';
import 'package:study_schedule/widgets/stats/stats_charts.dart';

enum Segments {
  achivementRate("Achivement Rate"),
  totalStudyTime("Total Study Time"),
  totalStudyAmount("Total Study Amount");

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

class StatsChartArea extends StatefulWidget {
  final List<Todo> todoList;
  const StatsChartArea({
    super.key,
    required this.todoList
  });

  @override
  State<StatefulWidget> createState() => _StatsChartArea();
}

class _StatsChartArea extends State<StatsChartArea> {
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

        StatsCharts(
          segments: Segments.getEnumValueFromString(selectedFilter),
          todoList: widget.todoList,
        ),
      ],
    );
  }
}
