import 'package:hive/hive.dart';

part 'alarm_model.g.dart';

@HiveType(typeId: 0)
class AlarmModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String time;

  @HiveField(2)
  String label;

  @HiveField(3)
  bool isEnabled;

  @HiveField(4)
  List<int> repeatDays;

  @HiveField(5)
  DateTime createdAt;

  AlarmModel({
    required this.id,
    required this.time,
    required this.label,
    this.isEnabled = true,
    this.repeatDays = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'time': time,
    'label': label,
    'isEnabled': isEnabled,
    'repeatDays': repeatDays,
    'createdAt': createdAt.toIso8601String(),
  };

  factory AlarmModel.fromJson(Map<String, dynamic> json) => AlarmModel(
    id: json['id'],
    time: json['time'],
    label: json['label'],
    isEnabled: json['isEnabled'] ?? true,
    repeatDays: List<int>.from(json['repeatDays'] ?? []),
    createdAt: DateTime.parse(json['createdAt']),
  );
}
