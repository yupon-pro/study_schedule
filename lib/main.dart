import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_schedule/providers/todo_state.dart';
import 'package:study_schedule/repository/local_todo.dart';
import 'package:study_schedule/screens/stats_screen.dart';
import 'package:study_schedule/screens/tasks_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TodoState(todoRep: TodoStore()),
      child: const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2, 
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Scheduled Study Tasks"),
            bottom: const TabBar(tabs: [
              Tab(icon: Icon(Icons.home)),
              Tab(icon: Icon(Icons.analytics))
            ]),
          ),
          body: const TabBarView(children: [
            TasksScreen(),
            StatsScreen(),
          ])
        ),
      ),
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
    );
  }
}
