import "package:study_schedule/active_records/todo.dart";

abstract class TodoRepository {
  Future<List<Todo>> findAll();
  Future<List<Todo>> findByDates(List<DateTime> dates);
  // You must narrow down some kinds of data like achivement, category and so on, 
  // after withdrawing whole data from database for a certain period.
  Future<void> save(Todo todo);
  Future<void> saveAll(List<Todo> todos);
  Future<void> update(Todo todo);
  Future<void> updateAll(List<Todo> todos);
  Future<void> delete(String id);
}