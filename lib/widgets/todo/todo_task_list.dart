import 'package:flutter/material.dart';
import 'package:study_schedule/models/todo.dart';
import 'package:study_schedule/widgets/todo/todo_task.dart';

class TodoTaskList extends StatelessWidget {
  final List<Todo> todoList;
  const TodoTaskList({
    super.key,
    required this.todoList,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        children: todoList
          .map((todo) => TodoTask(todo: todo))
          .toList(),
      ),
    );
  }
}