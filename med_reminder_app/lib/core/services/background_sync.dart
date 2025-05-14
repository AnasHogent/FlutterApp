import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:med_reminder_app/core/di/dependency_injection.dart' as di;
import 'package:med_reminder_app/core/services/init_hive.dart';
import 'package:med_reminder_app/core/services/sync_service.dart';
import 'package:med_reminder_app/firebase_options.dart';

@pragma('vm:entry-point')
void backgroundSyncCallback() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await initHive();

  await di.initDI();
  await di.sl<SyncService>().syncAllPending();
}

Future<void> scheduleDailyBackgroundSync() async {
  await AndroidAlarmManager.initialize();

  await AndroidAlarmManager.periodic(
    const Duration(hours: 6),
    0,
    backgroundSyncCallback,
    exact: true,
    wakeup: true,
  );
}
