import "package:study_schedule/repository/todo.dart";
import "package:study_schedule/models/todo.dart";
import "package:shared_preferences/shared_preferences.dart";
import "dart:convert";

class TodoStore implements TodoRepository {
  static const String _key = "todo";

  @override
  Future<List<Todo>> findAll() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.map((item) => Todo.fromJson(json.decode(item))).toList();
  }

  @override
  Future<List<Todo>> findByDates(List<DateTime> dates) async {
    final all = await findAll();
    return all.where((todo) {
      return dates.any((d) => 
        d.year == todo.date.year && 
        d.month == todo.date.month && 
        d.day == todo.date.day
      );
    }).toList();
  }

  @override
  Future<void> save(Todo todo) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await findAll(); // 既存データを取得
    all.add(todo);
    
    // toJson() を介して encode する
    final target = all.map((m) => json.encode(m.toJson())).toList();
    await prefs.setStringList(_key, target);
  }

  @override
  Future<void> update(Todo todo) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await findAll();
    
    final index = all.indexWhere((prev) => prev.id == todo.id);
    if (index != -1) {
      all[index] = todo;
      final target = all.map((m) => json.encode(m.toJson())).toList();
      await prefs.setStringList(_key, target);
    }
  }

  @override
  Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await findAll();
    
    all.removeWhere((prev) => prev.id == id);
    final target = all.map((m) => json.encode(m.toJson())).toList();
    await prefs.setStringList(_key, target);
  }
}