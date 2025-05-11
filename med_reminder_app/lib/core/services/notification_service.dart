import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:med_reminder_app/models/medication_reminder.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin;

  static const AndroidNotificationChannel _defaultChannel =
      AndroidNotificationChannel(
        'med_channel',
        'Medication Reminders',
        description: 'Reminders to take your medication',
        importance: Importance.high,
      );

  NotificationService(this._plugin);

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    final settings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings);

    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      if (androidInfo.version.sdkInt >= 33) {
        await _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission();
      }

      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_defaultChannel);
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    final box = await Hive.openBox('settings');
    final isEnabled = box.get('notifications_enabled', defaultValue: true);
    if (!isEnabled) return;

    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _defaultChannel.id,
          _defaultChannel.name,
          channelDescription: _defaultChannel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  Future<void> scheduleMedicationReminder(MedicationReminder reminder) async {
    final plugin = _plugin;

    for (int i = 0; i < reminder.times.length; i++) {
      final timeString = reminder.times[i];
      final timeParts = timeString.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      tz.TZDateTime scheduledDate = _nextInstanceOfTime(hour, minute);

      if (scheduledDate.isBefore(
        tz.TZDateTime.from(reminder.startDate, tz.local),
      )) {
        scheduledDate = scheduledDate.add(Duration(days: 1));
      }

      if (reminder.endDate != null &&
          scheduledDate.isAfter(
            tz.TZDateTime.from(reminder.endDate!, tz.local),
          )) {
        continue;
      }

      await plugin.zonedSchedule(
        reminder.id.hashCode + i,
        'Time to take ${reminder.name}',
        "Don't forget to take your medication",
        //'Dosage: ${reminder.dosage}',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'med_channel',
            'Medication Reminders',
            channelDescription: 'Reminders to take your medication',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  Future<void> addReminder(MedicationReminder reminder) async {
    for (int i = 0; i < reminder.times.length; i++) {
      final timeParts = reminder.times[i].split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      tz.TZDateTime scheduledDate = _nextInstanceOfTime(hour, minute);

      if (scheduledDate.isBefore(
        tz.TZDateTime.from(reminder.startDate, tz.local),
      )) {
        scheduledDate = scheduledDate.add(Duration(days: 1));
      }

      if (reminder.endDate != null &&
          scheduledDate.isAfter(
            tz.TZDateTime.from(reminder.endDate!, tz.local),
          )) {
        continue;
      }

      final int id = reminder.id.hashCode + i;

      await _plugin.zonedSchedule(
        id,
        'Time to take ${reminder.name}',
        "Don't forget to take your medication",
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'med_channel',
            'Medication Reminders',
            channelDescription: 'Reminders to take your medication',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  Future<void> cancelReminder(MedicationReminder reminder) async {
    for (int i = 0; i < reminder.times.length; i++) {
      final notificationId = reminder.id.hashCode + i;
      await _plugin.cancel(notificationId);
    }
  }

  Future<void> updateReminder(MedicationReminder reminder) async {
    await cancelReminder(reminder);
    await addReminder(reminder);
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _plugin.pendingNotificationRequests();
  }
}
