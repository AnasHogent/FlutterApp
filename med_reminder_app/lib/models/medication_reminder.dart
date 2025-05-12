import 'package:hive/hive.dart';

part 'medication_reminder.g.dart';

@HiveType(typeId: 0)
class MedicationReminder extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<String> times; //HH:mm

  @HiveField(3)
  DateTime startDate;

  @HiveField(4)
  DateTime? endDate;

  @HiveField(5)
  int repeatDays;

  @HiveField(6)
  bool isSynced;

  MedicationReminder({
    required this.id,
    required this.name,
    required this.times,
    required this.startDate,
    this.endDate,
    required this.repeatDays,
    required this.isSynced,
  });
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'times': times,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'repeatDays': repeatDays,
    };
  }

  factory MedicationReminder.fromJson(Map<String, dynamic> json) {
    return MedicationReminder(
      id: json['id'] as String,
      name: json['name'] as String,
      times: List<String>.from(json['times'] ?? []),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate:
          json['endDate'] != null
              ? DateTime.parse(json['endDate'] as String)
              : null,
      repeatDays: json['repeatDays'] as int,
      isSynced: json['isSynced'] ?? true,
    );
  }
}
