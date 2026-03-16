import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:study_schedule/models/todo.dart';
import 'package:study_schedule/providers/todo_state.dart';
import 'package:study_schedule/widgets/todo/todo_calendar.dart';
import 'package:study_schedule/widgets/todo/todo_time_picker.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
// build contextの型の拡張のためにproviderのインポートが必要。

enum TaskFrequency {
  once(label: 'this date'),
  weekends(label: 'weekends'),
  weekdays(label: 'weekdays'),
  everyday(label: 'weeklong');

  final String label;
  const TaskFrequency({required this.label});
}

class TodoTaskForm extends StatefulWidget {
  const TodoTaskForm({super.key});

  @override
  State<StatefulWidget> createState() => _TodoTaskFormState();
}

class _TodoTaskFormState extends State<TodoTaskForm> {
  bool _isLoading = false;
  void _setLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};

  TaskFrequency _selectedFrequency = TaskFrequency.once;
  int _targetWeeks = 0;


  final _hours = [for (var i = 0; i <= 24; i++) i];
  final _minutes = [for (var i = 0; i <= 59; i++) i];
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;

  void onSubmit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // これで TextField の値が確定する

      final todoState = context.read<TodoState>();

      final uuid = Uuid();
      String title = _formData["title"];
      int? targetStudyHours = _formData.containsKey("targetStudyHours") ? _formData["targetStudyHours"] : null;
      int? targetStudyMinutes = _formData.containsKey("targetStudyMinutes") ? _formData["targetStudyMinutes"] : null;
      int? targetStudyTime = targetStudyHours == null && targetStudyMinutes == null 
      ? null
      : (targetStudyHours ?? 0) * 60 + (targetStudyMinutes ?? 0);
      int? targetStudyAmount = _formData.containsKey("targetStudyAmount") ? int.parse(_formData["targetStudyAmount"]) : null;
      
      try{
        _setLoading(true);

        List<DateTime> dueDateList = pickupDueDates(
          targetDate: _selectedDay, 
          days: _selectedFrequency, 
          weeks: _targetWeeks
        );

        if(dueDateList.isEmpty) {
          throw "Something went wrong. Please report to developer";
        }

        List<Todo> todoList = dueDateList
          .map((targetDate) => Todo(
            id: uuid.v4(), 
            title: title, 
            targetStudyTime: targetStudyTime,
            targetStudyAmount: targetStudyAmount,
            date: targetDate
          ))
          .toList();

        await todoState.saveTodos(todoList);
        

        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("You successfully saved task!"))
          );
          Navigator.of(context).pop();
        }

      } catch (e) {
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You failed to record tasks!"))
        );
        }

      } finally{
        _setLoading(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Task"),
        centerTitle: true,
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                buildSectionTitle(theme, "Basic Information", Icons.edit_note),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: "Task Title",
                      hintText: "What are you studying?",
                      prefixIcon: const Icon(Icons.title),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
                    ),
                    inputFormatters: [LengthLimitingTextInputFormatter(50)],
                    validator: (value) => (value == null || value.isEmpty) ? 'Please write a title' : null,
                    onSaved: (val) => _formData["title"] = val,
                  ),
                ),

                const SizedBox(height: 24),

                buildSectionTitle(theme, "Study Goals", Icons.track_changes),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 20),
                            const SizedBox(width: 8),
                            Text("Target Time", style: theme.textTheme.titleSmall),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TodoTimePicker(
                                label: "H",
                                items: _hours,
                                handleTimeChange: (index) => _formData["targetStudyHours"] = _hours[index],
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text(":", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            ),
                            Expanded(
                              child: TodoTimePicker(
                                label: "M",
                                items: _minutes,
                                handleTimeChange: (index) => _formData["targetStudyMinutes"] = _minutes[index],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 32),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Target Amount",
                            prefixIcon: Icon(Icons.menu_book),
                            suffixText: "pages/questions",
                            border: UnderlineInputBorder(),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                          validator: (val) {
                            if (val == null) {
                              return null;
                            }
                            if(val.isEmpty || val == "0") {
                              return "Please enter 1 or more";
                            }
                            return null;
                          },
                          onSaved: (val) {
                            if (val != null && val.isNotEmpty) _formData["targetStudyAmount"] = int.parse(val);
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                buildSectionTitle(theme, "Schedule & Repeat", Icons.calendar_month),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TodoCalendar(
                          focusedDay: _focusedDay,
                          selectedDay: _selectedDay,
                          format: _calendarFormat,
                          thisYear: DateTime.now().year,
                          onHandleDay: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                            });
                          },
                          onHandleFormat: (format) => setState(() => _calendarFormat = format),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      
                      DropdownButtonFormField<TaskFrequency>(
                        initialValue: _selectedFrequency,
                        decoration: const InputDecoration(
                          labelText: "Repeat Frequency",
                          prefixIcon: Icon(Icons.repeat),
                          border: OutlineInputBorder(),
                        ),
                        items: TaskFrequency.values
                            .map((freq) => DropdownMenuItem(value: freq, child: Text(freq.label)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedFrequency = val);
                        },
                      ),

                      if (_selectedFrequency != TaskFrequency.once) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Duration",
                            suffixText: "weeks",
                            helperText: "For how many weeks should this repeat?",
                            border: OutlineInputBorder(),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(1),
                          ],
                          validator: (val) {
                            if (val == null || val.isEmpty || val == "0") return "Please enter 1 or more";
                            return null;
                          },
                          onChanged: (val) {
                            final weeks = int.tryParse(val);
                            if (weeks != null) setState(() => _targetWeeks = weeks);
                          },
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FilledButton.icon(
                    onPressed: _isLoading ? null : onSubmit,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.check_circle_outline),
                    label: const Text("Confirm & Save", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

List<DateTime> pickupDueDates({
  required DateTime targetDate, 
  required TaskFrequency days, 
  required int weeks,
}) {
  List<DateTime> dates = [];

  for (var j = 0; j < weeks; j++) {
    for (var i = 0; i < 7; i++) {

      DateTime dueDate = targetDate.add(Duration(days: (j * 7) + i));

      switch (days) {
        case TaskFrequency.once:
          return [dueDate];

        case TaskFrequency.everyday:
          dates.add(dueDate);
          break;

        case TaskFrequency.weekends:
          if(dueDate.weekday == DateTime.saturday || dueDate.weekday == DateTime.sunday) {
            dates.add(dueDate);
          }
          break;

        case TaskFrequency.weekdays:
          if (DateTime.monday <= dueDate.weekday && dueDate.weekday <= DateTime.friday) {
            dates.add(dueDate);
          }
          break;
      }
    }
  }

  return dates;
}


Widget buildSectionTitle(ThemeData theme, String title, IconData icon) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
    child: Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 20),
        const SizedBox(width: 8),
        Text(title, style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        )),
      ],
    ),
  );
}