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
}
