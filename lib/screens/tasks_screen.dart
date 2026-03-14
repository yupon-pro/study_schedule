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

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<String> segments = ["All", "Ongoing", "Completed"];
  String selectedFilter = "All";

  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;

  void onHandleFilter(String newSelection) {
    setState(() {
      selectedFilter = newSelection;
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
        switch (selectedFilter) {
          case "All":
            return true;
          case "Ongoing":
            return todo.achievement != Achievement.fulfilled;
          case "Completed":
            return todo.achievement == Achievement.fulfilled;
          default:
            return false;
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
            segments: segments, 
            currentSelection: selectedFilter, 
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