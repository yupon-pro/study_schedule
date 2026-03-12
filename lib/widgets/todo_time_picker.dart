import 'package:flutter/cupertino.dart';

// everything is widget
// 関数切り出しをしたくなるけど、それはflutterの作法ではない。

class TodoTimePicker extends StatelessWidget {
  final String label;
  final List<int> items;
  final int? selectedValue;
  final ValueChanged<int> handleTimeChange;

  const TodoTimePicker({
    super.key,
    required this.label,
    required this.items,
    required this.handleTimeChange,
    this.selectedValue,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          height: 100,
          child: CupertinoPicker(
            scrollController: FixedExtentScrollController(
              initialItem: items.indexOf(selectedValue ?? 0),
            ),
            itemExtent: 32,
            onSelectedItemChanged: (index) => handleTimeChange(items[index]),
            children: items.map((e) => Center(child: Text(e.toString()))).toList(),
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}
