import 'package:hive/hive.dart';
import 'package:med_reminder_app/core/services/notification_service.dart';
import 'package:med_reminder_app/core/services/sync_service.dart';
import 'package:med_reminder_app/models/medication_reminder.dart';

class UserSessionService {
  final NotificationService _notificationService;
  final SyncService _syncService;

  UserSessionService(this._notificationService, this._syncService);

  Future<void> setupUserSession() async {
    Hive.box<MedicationReminder>('medications').clear();
    await _notificationService.cancelAllNotifications();

    await _syncService.syncAllPending();

    final box = Hive.box<MedicationReminder>('medications');
    for (final reminder in box.values) {
      if (!reminder.isDeleted) {
        await _notificationService.scheduleMedicationReminder(reminder);
      }
    }
  }

  Future<void> clearUserSession() async {
    await _notificationService.cancelAllNotifications();
    await Hive.box<MedicationReminder>('medications').clear();
  }
}
