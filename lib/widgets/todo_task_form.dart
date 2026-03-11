import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:study_schedule/models/todo.dart';
import 'package:study_schedule/providers/todo_state.dart';
import 'package:study_schedule/widgets/todo_calendar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
// build contextの型の拡張のためにproviderのインポートが必要。

enum PreferedDays {
  everyday,
  weekdays,
  weekends,
}

class TodoTaskForm extends StatefulWidget {
  const TodoTaskForm({super.key});

  @override
  State<StatefulWidget> createState() => _TodoTaskFormState();
}

class _TodoTaskFormState extends State<TodoTaskForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};

  final Map<String, dynamic> dueDateFilter = {
    "this date": null,
    "weekends": PreferedDays.weekends, 
    "weekdays": PreferedDays.weekdays,
    "weeklong": PreferedDays.everyday,
  };

  String _selectedDateFilter = "this date";
  int _targetWeeks = 0;


  final _hours = [for (var i = 0; i <= 24; i++) i];
  final _minutes = [for (var i = 0; i <= 59; i++) i];
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;

  void onSubmit() {
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
      
      if(_selectedDateFilter == "this date") {
        DateTime targetDate = _selectedDay;
        todoState.saveTodo(Todo(
          id: uuid.v4(), 
          title: title, 
          targetStudyTime: targetStudyTime,
          targetStudyAmount: targetStudyAmount,
          date: targetDate
        ));
      }else{
        List<DateTime> dueDateList = pickupDueDates(
          targetDate: _selectedDay, 
          days: dueDateFilter[_selectedDateFilter], 
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

        todoState.saveTodos(todoList);
      }
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Todo Task Form"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[

                TextFormField(
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Task Title",
                    border: OutlineInputBorder(),
                  ),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(50),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  onSaved: (val) {
                    _formData["title"] = val;
                  },
                ),

                FormField(
                  builder: (state) {
                    return Row(
                      children: <Widget>[
                        SizedBox(
                          width: 80,
                          height: 100,
                          child: CupertinoPicker(
                            scrollController: FixedExtentScrollController(
                              initialItem: 0,
                            ),
                            itemExtent: 32,
                            onSelectedItemChanged: (index) {
                              _formData["targetStudyHours"] = _hours[index];
                            },
                            children: _hours.map((e) => Center(child: Text("${e.toString()} hours"))).toList(),
                          ),
                        ),

                        SizedBox(
                          width: 80,
                          height: 100,
                          child: CupertinoPicker(
                            scrollController: FixedExtentScrollController(
                              initialItem: 0,
                            ),
                            itemExtent: 32,
                            onSelectedItemChanged: (index) {
                              _formData["targetStudyMinutes"] = _minutes[index];
                            },
                            children: _minutes.map((e) => Center(child: Text("${e.toString()} minutes"))).toList(),
                          ),
                        )
                      ],
                    );
                  }
                ),

                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Study amount",
                    suffixText: "pages/questions",
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  onSaved: (val) {
                    if (val != null && val.isNotEmpty) {
                      _formData["targetStudyAmount"] = int.parse(val);
                    }
                  },
                ),

                Column(
                  children: <Widget>[
                    TodoCalendar(
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
                      onHandleFormat: (format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      },
                    ),
                    DropdownButton(
                      items: dueDateFilter
                        .keys
                        .map((filter) => DropdownMenuItem(value: filter, child: Text(filter)))
                        .toList(), 
                      value: _selectedDateFilter, 
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedDateFilter = val;
                          });
                        }
                      }
                    ),
                    
                    _selectedDateFilter != "this date" 
                    ? TextFormField(
                        keyboardType: TextInputType.number,
                        // controller: _studyAmountEditingController,
                        decoration: const InputDecoration(
                          labelText: "How many weeks?",
                          suffixText: "weeks",
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(1),
                        ],
                        validator: (val) {
                          if (val == null || val.isEmpty || val == "0") {
                            return "Please select weeks more than 1 weeks";
                          }

                          return null;
                        },
                        onChanged: (val) {
                          setState(() {
                            final weeks = int.tryParse(val);
                            if (weeks != null) {
                              _targetWeeks = weeks;
                            }
                          });
                        },
                      ) 
                    : SizedBox.shrink()
                  ],
                ),

                Container(
                  margin: EdgeInsets.only(top: 20),

                  child: SizedBox(
                    height: 30,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => onSubmit(),
                      child: Text(
                        "Submit",
                      ),
                    ),
                  ),
                ),

              ],
            ), 
          ),
        )
      )
    );
  }
}

List<DateTime> pickupDueDates({
  required DateTime targetDate, 
  required PreferedDays? days, 
  required int weeks,
}) {
  List<DateTime> dates = [];
  if (days == null) {
    return dates;
  }

  for (var j = 0; j < weeks; j++) {
    for (var i = 0; i < 7; i++) {

      DateTime dueDate = targetDate.add(Duration(days: (j * 7) + i));

      switch (days) {
        case PreferedDays.everyday:
          dates.add(dueDate);
          break;

        case PreferedDays.weekends:
          if(dueDate.weekday == DateTime.saturday || dueDate.weekday == DateTime.sunday) {
            dates.add(dueDate);
          }
          break;

        case PreferedDays.weekdays:
          if (DateTime.monday <= dueDate.weekday && dueDate.weekday <= DateTime.friday) {
            dates.add(dueDate);
          }
          break;
      }
    }
  }

  return dates;
}
