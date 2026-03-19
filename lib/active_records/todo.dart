import 'package:flutter/foundation.dart';

enum Achievement {
  fulfilled,
  partial,
  failure,
  none,
}

@immutable // インスタンスが不変であることを示すアノテーション
class Todo {
  final String id;
  final String title;
  final DateTime date;

  // 任意項目（Null許容）
  final int? targetStudyTime;
  final int? actualStudyTime;
  final int? targetStudyAmount;
  final int? actualStudyAmount;
  final DateTime? delayFrom;
  final String? remarks;

  final Achievement achievement;

  const Todo({
    required this.id,
    required this.title,
    required this.date,
    this.achievement = Achievement.none,
    this.targetStudyTime,
    this.actualStudyTime,
    this.targetStudyAmount,
    this.actualStudyAmount,
    this.delayFrom,
    this.remarks,
  });

  /// 特定のフィールドだけを更新した新しいインスタンスを作成する
  Todo copyWith({
    String? title,
    DateTime? date,
    Achievement? achievement,
    int? targetStudyTime,
    int? actualStudyTime,
    int? targetStudyAmount,
    int? actualStudyAmount,
    DateTime? delayFrom,
    String? remarks,
  }) {
    return Todo(
      id: id, // IDは常に固定
      title: title ?? this.title,
      date: date ?? this.date,
      achievement: achievement ?? this.achievement,
      targetStudyTime: targetStudyTime ?? this.targetStudyTime,
      actualStudyTime: actualStudyTime ?? this.actualStudyTime,
      targetStudyAmount: targetStudyAmount ?? this.targetStudyAmount,
      actualStudyAmount: actualStudyAmount ?? this.actualStudyAmount,
      delayFrom: delayFrom ?? this.delayFrom,
      remarks: remarks ?? this.remarks,
    );
  }

  /// JSON (Map) からインスタンスを生成する
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json["id"] as String,
      title: json["title"] as String,
      date: DateTime.parse(json["date"] as String),
      targetStudyTime: json["targetStudyTime"] as int?,
      actualStudyTime: json["actualStudyTime"] as int?,
      targetStudyAmount: json["targetStudyAmount"] as int?,
      actualStudyAmount: json["actualStudyAmount"] as int?,
      delayFrom: json["delayFrom"] != null 
          ? DateTime.parse(json["delayFrom"] as String) 
          : null,
      remarks: json["remarks"] as String?,
      achievement: Achievement.values.byName(json["achievement"] ?? "none"),
    );
  }

  /// インスタンスを JSON (Map) に変換する
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "date": date.toIso8601String(),
      "targetStudyTime": targetStudyTime,
      "actualStudyTime": actualStudyTime,
      "targetStudyAmount": targetStudyAmount,
      "actualStudyAmount": actualStudyAmount,
      "delayFrom": delayFrom?.toIso8601String(),
      "achievement": achievement.name,
      "remarks": remarks,
    };
  }
}