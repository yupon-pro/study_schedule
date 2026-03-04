import "package:flutter/foundation.dart";
import "package:study_schedule/models/todo.dart";
import "package:study_schedule/repository/todo.dart";

class TodoState extends ChangeNotifier {
  final TodoRepository todoRep;

  List<Todo> _todos = [];
  bool _isLoading = false;

  List<Todo> get todos => _todos;
  bool get isLoading => _isLoading;

  TodoState({required this.todoRep}) {
    loadTodos();
  }

  Future<void> loadTodos() async {
    _isLoading = true;
    notifyListeners();

    try {
      _todos = await todoRep.findAll();
    } catch (e) {
      debugPrint("エラーが発生しました: $e");
    } finally {
      _isLoading = false;
      notifyListeners(); // ロード完了を通知
    }
  }

  List<Todo> getTodosByDate(DateTime selectedDate) {
    return _todos.where((todo) {
      return todo.date.year == selectedDate.year &&
             todo.date.month == selectedDate.month &&
             todo.date.day == selectedDate.day;
    }).toList();
  }

  Future<void> saveTodo(Todo todo) async {
    await todoRep.save(todo);
    await loadTodos(); 
  }

  Future<void> updateTodo(Todo todo) async {
    await todoRep.update(todo);
    await loadTodos();
  }

  Future<void> deleteTodo(String id) async {
    await todoRep.delete(id);
    await loadTodos();
  }
}