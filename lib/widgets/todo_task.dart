import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:study_schedule/models/todo.dart';

class TodoTask extends StatefulWidget {
  final Todo todo;
  const TodoTask({
    super.key, 
    required this.todo
  });

  @override
  State<TodoTask> createState() => _TodoTaskState();
}

class _TodoTaskState extends State<TodoTask> {
  int? actualStudyHours;
  int? actualStudyMiniutes;

  int? actualStudyAmount;

  final _hours = [for(var i = 1; i <= 24; i++) i];
  final _minutes = [for(var i = 1; i <= 60; i++) i];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 12,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF55C500),
          borderRadius: BorderRadius.all(
            Radius.circular(32)
          )
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.todo.title,
              style: const TextStyle(
                fontSize: 10,
              )
            ),
            widget.todo.targetStudyAmount != null 
            ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoPicker(
                  itemExtent: 30, 
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      // \d（数字）が1回以上続く部分を探す
                      final match = RegExp(r'\d+').firstMatch(_hours[index].toString());
                      final num = match?.group(0);

                      if (num != null) {
                        actualStudyHours = int.parse(num);
                      }
                    });
                  }, 
                  children: _hours.map((e) => Text("${e.toString()}時間")).toList()
                ),
                CupertinoPicker(
                  itemExtent: 30, 
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      // \d（数字）が1回以上続く部分を探す
                      final match = RegExp(r'\d+').firstMatch(_hours[index].toString());
                      final num = match?.group(0);

                      if (num != null) {
                        actualStudyMiniutes = int.parse(num);
                      }
                    });
                  }, 
                  children: _minutes.map((e) => Text("${e.toString()}分")).toList()
                )
              ],
            ) 
            : SizedBox.shrink(),

            widget.todo.actualStudyAmount != null
            ? FormField(builder: )
            : SizedBox.shrink(),
          ]
        ),
      )
    );
  }

}