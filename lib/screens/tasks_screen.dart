import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:study_schedule/local_store/display_carryover.dart';
import 'package:study_schedule/models/todo.dart';
import 'package:study_schedule/providers/todo_state.dart';
import 'package:study_schedule/widgets/common/filter_segment.dart';
import 'package:study_schedule/widgets/todo/todo_calendar.dart';
import 'package:study_schedule/widgets/todo/todo_delay_dialog.dart';
import 'package:study_schedule/widgets/todo/todo_task_form.dart';
import 'package:study_schedule/widgets/todo/todo_task_list.dart';
import 'package:table_calendar/table_calendar.dart';

enum Segments {
  all("All"),
  ongoing("Ongoing"),
  completed("Completed");

  final String displayName;
  const Segments(this.displayName);

  static List<String> getStringDisplayName() {
    return Segments.values.map((filter) => filter.displayName).toList();
  }

  static Segments getEnumValueFromString(String displayName) {
    return Segments.values.firstWhere(
      (filter) => filter.displayName == displayName,
      orElse: () => Segments.all,
    );
  }
}

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final List<String> _segments = Segments.getStringDisplayName();
  Segments _selectedFilter = Segments.all;

  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;

  void onHandleFilter(String newSelection) {
    setState(() {
      _selectedFilter = Segments.getEnumValueFromString(newSelection);
    });
  }

  void _showTodoForm() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return TodoTaskForm();
        })
    );
  }

  void _checkYesterdayTasks() async {
    final todoState = context.read<TodoState>();

    final isDisplayed = await isAlreadyDisplayed();
    if(!mounted) {
      return;
    }

    if(!isDisplayed) {
      setDisplay();

      final yesterdayIncompleteTasks = todoState
        .getTodosByDate(DateTime.now().subtract(Duration(days: 1)))
        .where((todo) => todo.achievement != Achievement.fulfilled)
        .toList();

      if (yesterdayIncompleteTasks.isNotEmpty) {
        showDialog(
          context: context,
          barrierDismissible: false, // 外側をタップしても閉じないようにする
          builder: (context) => TodoDelayDialog(todoList: yesterdayIncompleteTasks),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkYesterdayTasks();
    });    
  }

  @override
  Widget build(BuildContext context) {
    final int thisYear = DateTime.now().year;
    final todoState = context.watch<TodoState>();
    
    
    final filteredTodoList = todoState
      .getTodosByDate(_selectedDay)
      .where((todo) {
        switch (_selectedFilter) {
          case Segments.all:
            return true;
          case Segments.ongoing:
            return todo.achievement != Achievement.fulfilled;
          case Segments.completed:
            return todo.achievement == Achievement.fulfilled;
        }
      })
      .toList();

    String todayStr = DateFormat("yyyy/MM/dd").format(_selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: Text("$todayStr Task"),
      ),
      body: Column(
        children: <Widget>[
          FilterSegment(
            segments: _segments, 
            currentSelection: _selectedFilter.displayName, 
            onHandleFilter: onHandleFilter
          ),

          TodoCalendar(
            focusedDay: _focusedDay, 
            selectedDay: _selectedDay, 
            format: _calendarFormat, 
            thisYear: thisYear, 
            onHandleDay: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onHandleFormat: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
          ),

          TodoTaskList(todoList: filteredTodoList),
        ],
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: _showTodoForm,
        child: const Icon(Icons.add),  
      ),
    );
  }
}