
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class TodoCalendar extends StatefulWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final CalendarFormat format;
  final int thisYear;
  final Function(DateTime selectedDay, DateTime focusedDay) onHandleDay;
  final Function(CalendarFormat format) onHandleFormat;
   
  const TodoCalendar({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.format,
    required this.thisYear,
    required this.onHandleDay,
    required this.onHandleFormat,
  });

  @override
  State<StatefulWidget> createState() => _TodoCalendarState();
}

class _TodoCalendarState extends State<TodoCalendar> {
  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      focusedDay: widget.focusedDay,
      firstDay: DateTime.utc(widget.thisYear - 5, 1, 1),
      lastDay: DateTime.utc(widget.thisYear + 5, 12, 31),
      selectedDayPredicate: (day) => isSameDay(widget.selectedDay, day),
      calendarFormat: widget.format,
      onDaySelected: (selectedDay, focusedDay) => widget.onHandleDay(selectedDay, focusedDay),
      onFormatChanged: (format) => widget.onHandleFormat(format),
    );
  }
}