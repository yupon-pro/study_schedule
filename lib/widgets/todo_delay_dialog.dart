import 'package:flutter/material.dart';
import 'package:study_schedule/models/todo.dart';
import 'package:study_schedule/providers/todo_state.dart';
import 'package:provider/provider.dart';

class TodoDelayDialog extends StatefulWidget {
  final List<Todo> todoList;
  const TodoDelayDialog({
    super.key,
    required this.todoList,
  });

  @override
  State<StatefulWidget> createState() => _TodoDelayDialogState();
}

class _TodoDelayDialogState extends State<TodoDelayDialog> {
  bool _isLoading = false;
  late List<bool> todoCarriedList;

  @override
  void initState() {
    todoCarriedList = List<bool>.filled(widget.todoList.length, false);
    super.initState();
  }

  void loadTrigger(bool flag) {
    if (mounted) {
      setState(() {
        _isLoading = flag;
      });
    }
  }

  void handleCarryOverTasks() async {
    final todoState = context.read<TodoState>();
    List<Todo> todoCarryOverTasks = [];

    for (int i = 0; i < todoCarriedList.length; i++) {
      if (todoCarriedList[i]) {
        final todo = widget.todoList[i];
        final newTodo = todo.copyWith(
          date: DateTime.now(),
          delayFrom: todo.date,
        );
        todoCarryOverTasks.add(newTodo);
      }
    }

    if (todoCarryOverTasks.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    loadTrigger(true);
    try {
      // Provider経由で一括更新
      await todoState.updateTodos(todoCarryOverTasks);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Successfully carried over!"))
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to carry over..."))
        );
      }
    } finally {
      loadTrigger(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 画面サイズを取得して、ポップアップの大きさを調整
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        // 画面の幅の90%、高さの70%程度を占めるように設定
        width: screenSize.width * 0.9,
        height: screenSize.height * 0.7,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              "Oops!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              "You were so close to accomplishing tasks yesterday. Do you want to carry these tasks over to today?",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                TextButton(
                  onPressed: () {
                    bool isAllChecked = todoCarriedList.every((e) => e);
                    setState(() {
                      todoCarriedList = todoCarriedList.map((_) => !isAllChecked).toList();
                    });
                  }, 
                  child: Text(todoCarriedList.every((e) => e) ? "Unselect all" : "Do all"),
                ),
                Text(
                  "or Select each task.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                )
              ],
            ),

            const SizedBox(height: 20),
            
            // 1. ListView.builderをExpandedで囲い、領域を確保
            Expanded(
              child: ListView.builder(
                itemCount: widget.todoList.length,
                itemBuilder: (context, index) {
                  final todo = widget.todoList[index];
                  return CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(todo.title),
                    subtitle: Text("Original: ${todo.date.month}/${todo.date.day}"),
                    value: todoCarriedList[index],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          todoCarriedList[index] = val;
                        });
                      }
                    },
                  );
                },
              ),
            ),
            
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Skip"),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                    onPressed: _isLoading ? null : handleCarryOverTasks,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text("Carry Over"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}