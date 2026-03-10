import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:study_schedule/models/todo.dart';
import 'package:study_schedule/providers/todo_state.dart';
import 'package:provider/provider.dart';

class TodoTask extends StatefulWidget {
  final Todo todo;
  const TodoTask({
    super.key,
    required this.todo,
  });

  @override
  State<TodoTask> createState() => _TodoTaskState();
}

// 編集版も表示するには、初期の値をそれぞれフィールドにはじめから入れるようにしてあげたほうが良い。

class _TodoTaskState extends State<TodoTask> {
  int? actualStudyHours;
  int? actualStudyMinutes;
  int? actualStudyAmount;
  String? remarks;
  late Achievement? achievement;
  bool _isExpanded = false;

  final _hours = [for (var i = 0; i <= 24; i++) i];
  final _minutes = [for (var i = 0; i <= 59; i++) i];

  late TextEditingController _remarksEditingController;
  late TextEditingController _studyAmountEditingController;

  @override
  void initState() {
    int? studyDuration = widget.todo.actualStudyTime;
    if(studyDuration != null) {
      actualStudyHours = studyDuration ~/ 60;
      actualStudyMinutes = studyDuration % 60;
    }

    actualStudyAmount = widget.todo.actualStudyAmount;
    remarks = widget.todo.remarks;
    achievement = widget.todo.achievement;

    _remarksEditingController = TextEditingController(text: remarks);
    _studyAmountEditingController = TextEditingController(text: actualStudyAmount?.toString());
    
    super.initState();
  }  

  @override
  void dispose() {
    _remarksEditingController.dispose();
    _studyAmountEditingController.dispose();
    super.dispose();
  }

  // Providerを呼び出してデータを保存する処理
  void _saveToProvider() {
    final todoState = context.read<TodoState>();
    
    // Durationの再計算（hoursとminutesを統合）
    final totalDuration = 
      actualStudyHours == null && actualStudyMinutes == null 
      ? null 
      : (actualStudyHours ?? 0) * 60 + (actualStudyMinutes ?? 0);

    actualStudyAmount = int.tryParse(_studyAmountEditingController.text);
    remarks = _remarksEditingController.text;

    todoState.updateTodo(widget.todo.copyWith(
        actualStudyTime: totalDuration,
        actualStudyAmount: actualStudyAmount,
        remarks: remarks,
        achievement: achievement,
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF55C500),
          borderRadius: BorderRadius.all(Radius.circular(32)),
        ),
        child: Column(
          children: [
            // ヘッダー部分（タイトルと達成度ラジオボタン）
            ListTile(
              title: Text(
                widget.todo.title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              // 新しいバージョンではRadioGroupが推奨される。
              subtitle: RadioGroup<Achievement>(
                groupValue: achievement,
                onChanged: (val) {
                  setState(() {
                    achievement = val ?? Achievement.none;
                  });
                  _saveToProvider();
                }, 
                child: Row(
                  children: [
                    _achievementRadio(Achievement.fulfilled, "Complete!"),
                    _achievementRadio(Achievement.partial, "Partially"),
                    _achievementRadio(Achievement.failure, "Failure/Ignore"),
                  ],
                )
              )
            ),

            // 詳細入力（アコーディオン部分）
            ExpansionPanelList(
              elevation: 0,
              expandedHeaderPadding: EdgeInsets.zero,
              expansionCallback: (panelIndex, isExpanded) {
                setState(() {
                  _isExpanded = isExpanded;
                });
              },
              children: [
                ExpansionPanel(
                  canTapOnHeader: true,
                  backgroundColor: Colors.white,
                  headerBuilder: (context, isExpanded) {
                    return const ListTile(
                      title: Text("Record in detail", style: TextStyle(fontSize: 13)),
                    );
                  },
                  isExpanded: _isExpanded,
                  body: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // 時間入力（TargetTimeがある場合のみ）
                        if (widget.todo.targetStudyTime != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _timePicker("H", _hours, actualStudyHours, (val) {
                                setState(() => actualStudyHours = val);
                                _saveToProvider(); // 変更のたびに保存、または一括保存ボタンを置く
                              }),
                              _timePicker("M", _minutes, actualStudyMinutes, (val) {
                                setState(() => actualStudyMinutes = val);
                                _saveToProvider();
                              }),
                            ],
                          ),

                        const SizedBox(height: 16),

                        // 学習量入力（TargetAmountがある場合のみ）
                        if (widget.todo.targetStudyAmount != null)
                          TextField(
                            keyboardType: TextInputType.number,
                            controller: _studyAmountEditingController,
                            decoration: const InputDecoration(
                              labelText: "Study amount",
                              suffixText: "pages/questions",
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3),
                            ],
                          ),

                        const SizedBox(height: 16),

                        // メモ入力
                        TextField(
                          maxLines: 5,
                          controller: _remarksEditingController,
                          decoration: const InputDecoration(
                            labelText: "Take a note here",
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 16),

                        ElevatedButton(
                          onPressed: () => _saveToProvider(), 
                          child: const Text("Save"),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 達成度ラジオボタンのヘルパー
  Widget _achievementRadio(Achievement value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<Achievement>(
          value: value,
          activeColor: Colors.white,
        ),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white)),
      ],
    );
  }

  // CupertinoPickerのヘルパー
  Widget _timePicker(String label, List<int> items, int? selectedValue, ValueChanged<int> onChanged) {
    return Column(
      children: [
        SizedBox(
          width: 80,
          height: 100,
          child: CupertinoPicker(
            scrollController: FixedExtentScrollController(
              initialItem: items.indexOf(selectedValue ?? 0),
            ),
            itemExtent: 32,
            onSelectedItemChanged: (index) => onChanged(items[index]),
            children: items.map((e) => Center(child: Text(e.toString()))).toList(),
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}