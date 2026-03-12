import 'package:flutter/material.dart';

class TodoTaskFilter extends StatelessWidget {
  final List<String> segments;
  final String currentSelection;
  final ValueChanged<String> onHandleFilter;

  const TodoTaskFilter({
    super.key,
    required this.segments,
    required this.currentSelection,
    required this.onHandleFilter,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: segments.map((e) => ButtonSegment<String>(
        value: e,
        label: Padding(
          padding: EdgeInsets.all(2),
          child: Text(e, style: const TextStyle(fontSize: 14)),
        ),
      )).toList(),
      selected: {currentSelection},
      showSelectedIcon: false,
      onSelectionChanged: (newSelection) {
        onHandleFilter(newSelection.first);
      },
    );
  }
}