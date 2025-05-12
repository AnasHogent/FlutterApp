import 'dart:async';
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/rendering.dart';
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
    if (!await _hasExactAlarmPermission()) {
      await _openExactAlarmSettings();
      return;
    }

    for (int i = 0; i < reminder.times.length; i++) {
      await _scheduleReminder(reminder, i);
    }
  }

  Future<void> addReminder(MedicationReminder reminder) async {
    if (!await _hasExactAlarmPermission()) {
      await _openExactAlarmSettings();
      return;
    }

    for (int i = 0; i < reminder.times.length; i++) {
      await _scheduleReminder(reminder, i);
    }
  }

  Future<void> _scheduleReminder(MedicationReminder reminder, int index) async {
    final timeParts = reminder.times[index].split(':');
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
      return;
    }

    try {
      await _plugin.zonedSchedule(
        reminder.id.hashCode + index,
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
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint(
        'Error scheduling reminder for ${reminder.name} at $hour:$minute: $e',
      );
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
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

  Future<void> cancelReminder(MedicationReminder reminder) async {
    for (int i = 0; i < reminder.times.length; i++) {
      await _plugin.cancel(reminder.id.hashCode + i);
    }
  }

  Future<void> updateReminder(MedicationReminder reminder) async {
    await cancelReminder(reminder);
    await addReminder(reminder);
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _plugin.pendingNotificationRequests();
  }

  Future<bool> requestPermissionIfNeeded() async {
    final box = await Hive.openBox('settings');
    if (!box.containsKey('notifications_enabled')) {
      await box.put('notifications_enabled', false);
    }

    bool granted = false;

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        final androidPlugin =
            _plugin
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >();
        granted =
            await androidPlugin?.requestNotificationsPermission() ?? false;
      } else {
        granted = true;
      }
    } else {
      final status = await Permission.notification.status;
      if (status.isDenied ||
          status.isRestricted ||
          status.isPermanentlyDenied) {
        granted = (await Permission.notification.request()).isGranted;
      } else {
        granted = status.isGranted;
      }
    }

    if (granted) {
      await box.put('notifications_enabled', true);
    }

    return granted;
  }

  Future<bool> _hasExactAlarmPermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 31) {
        final androidPlugin =
            _plugin
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >();
        return await androidPlugin?.requestExactAlarmsPermission() ?? false;
      }
    }
    return true; // iOS or Android < 12
  }

  Future<void> _openExactAlarmSettings() async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt >= 31) {
      final intent = AndroidIntent(
        action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
      );
      await intent.launch();
    }
  }
}
