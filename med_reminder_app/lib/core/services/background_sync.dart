import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:med_reminder_app/core/di/dependency_injection.dart' as di;
import 'package:med_reminder_app/core/services/sync_service.dart';

@pragma('vm:entry-point')
void backgroundSyncCallback() async {
  await di.initDI();
  await di.sl<SyncService>().syncAllPending();
}

Future<void> scheduleDailyBackgroundSync() async {
  await AndroidAlarmManager.initialize();

  await AndroidAlarmManager.periodic(
    const Duration(minutes: 1),
    0,
    backgroundSyncCallback,
    exact: true,
    wakeup: true,
  );
}
