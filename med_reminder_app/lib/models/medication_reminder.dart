import 'package:hive/hive.dart';

part 'medication_reminder.g.dart';

@HiveType(typeId: 0)
class MedicationReminder extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<String> times; //HH:mm

  @HiveField(3)
  final DateTime startDate;

  @HiveField(4)
  final DateTime? endDate;

  @HiveField(5)
  final int repeatDays;

  @HiveField(6)
  final bool isSynced;

  MedicationReminder({
    required this.id,
    required this.name,
    required this.times,
    required this.startDate,
    this.endDate,
    required this.repeatDays,
    required this.isSynced,
  });
}
