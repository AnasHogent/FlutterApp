import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
      '@drawable/ic_stat_med',
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
    if (!(box.get('notifications_enabled', defaultValue: false))) return;

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

  Future<void> scheduleMedicationReminder(MedicationReminder reminder) async {
    if (!await _isAllowedToSchedule()) return;

    for (int i = 0; i < reminder.times.length; i++) {
      await _scheduleReminder(reminder, i);
    }
  }

  Future<void> addReminder(MedicationReminder reminder) async {
    if (!await _isAllowedToSchedule()) return;

    for (int i = 0; i < reminder.times.length; i++) {
      await _scheduleReminder(reminder, i);
    }
  }

  Future<void> updateReminder(
    MedicationReminder reminder,
    List<String> oldTimes,
  ) async {
    await cancelReminder(reminder, timesOverride: oldTimes);
    await addReminder(reminder);
  }

  Future<void> cancelReminder(
    MedicationReminder reminder, {
    List<String>? timesOverride,
  }) async {
    final times = timesOverride ?? reminder.times;

    for (int i = 0; i < times.length; i++) {
      await _plugin.cancel(reminder.id.hashCode + i);
    }
  }

  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return _plugin.pendingNotificationRequests();
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

  Future<bool> _isAllowedToSchedule() async {
    final box = await Hive.openBox('settings');
    final isEnabled = box.get('notifications_enabled', defaultValue: false);
    if (!isEnabled) return false;

    return await hasExactAlarmPermission();
  }

  Future<void> _scheduleReminder(MedicationReminder reminder, int index) async {
    final timeParts = reminder.times[index].split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    var scheduledDate = _nextInstanceOfTime(hour, minute);

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
      debugPrint('Error scheduling ${reminder.name} at $hour:$minute: $e');
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
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

  Future<bool> hasExactAlarmPermission() async {
    if (!Platform.isAndroid) return true;

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt >= 31) {
      final androidPlugin =
          _plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      return await androidPlugin?.requestExactAlarmsPermission() ?? false;
    }
    return true;
  }

  Future<void> rescheduleAllReminders() async {
    await cancelAllNotifications();

    final box = Hive.box<MedicationReminder>('medications');
    final reminders = box.values.toList();

    for (final reminder in reminders) {
      await scheduleMedicationReminder(reminder);
    }
  }
}
