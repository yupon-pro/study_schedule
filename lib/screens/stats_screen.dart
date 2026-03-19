import 'package:flutter/material.dart';
import 'package:study_schedule/providers/todo_state.dart';
import 'package:study_schedule/widgets/stats/stats_chart_area.dart';
import 'package:provider/provider.dart';


class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    
    final today = DateTime.now();
    final pastWeekDates = [for(var i = 0; i < 7; i++)  today.subtract(Duration(days: i))];

    final todoState = context.watch<TodoState>();
    final todoList = todoState.getTodosByDates(pastWeekDates);

    return Padding(
      padding: EdgeInsets.all(5),
      child: Column(
        children: [
          StatsChartArea(todoList: todoList)
        ],
      ),  
    );
  }
}