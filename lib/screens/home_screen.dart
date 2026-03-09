import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:study_schedule/models/todo.dart';
import 'package:study_schedule/providers/todo_state.dart';
import 'package:study_schedule/widgets/todo_task_list.dart';
import 'package:table_calendar/table_calendar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;

  @override
  Widget build(BuildContext context) {
    final int thisYear = DateTime.now().year;
    final todoState = context.watch<TodoState>();
    
    // 2. 選択された日付のリストを「今」のデータから抽出する
    final filteredTodoList = todoState.getTodosByDate(_selectedDay);

    String todayStr = DateFormat("yyyy/MM/dd").format(_selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: Text("$todayStr Task"),
      ),
      body: Column(
        children: <Widget>[
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(thisYear - 5, 1, 1),
            lastDay: DateTime.utc(thisYear + 5, 12, 31),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
          ),
          TodoTaskList(todoList: filteredTodoList),
        ],
      ),
    );
  }
}