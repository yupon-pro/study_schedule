import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_schedule/providers/todo_state.dart';
import 'package:study_schedule/repository/local_todo.dart';
import 'package:study_schedule/screens/home_screen.dart';

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
      title: 'Scheduled Study Tasks',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomeScreen(),
    );
  }
}
