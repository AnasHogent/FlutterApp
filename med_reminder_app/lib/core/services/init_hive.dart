import 'package:hive_flutter/adapters.dart';
import 'package:med_reminder_app/models/medication_reminder.dart';

Future<void> initHive() async {
  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(MedicationReminderAdapter());
  }

  await Hive.openBox('settings');
  await Hive.openBox<MedicationReminder>('medications');
}
