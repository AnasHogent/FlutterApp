import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:med_reminder_app/core/services/notification_service.dart';
import 'package:med_reminder_app/core/styling/app_colors.dart';
import 'package:med_reminder_app/core/styling/app_styles.dart';
import 'package:med_reminder_app/core/theme/theme_provider.dart';
import 'package:med_reminder_app/models/medication_reminder.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

final sl = GetIt.instance;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Box settingsBox;
  bool isNotificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    settingsBox = Hive.box('settings');

    isNotificationsEnabled = settingsBox.get(
      'notifications_enabled',
      defaultValue: true,
    );
  }

  Future<bool> _checkAndRequestNotificationPermission() async {
    final notificationService = sl<NotificationService>();

    final granted = await notificationService.requestPermissionIfNeeded();
    if (!granted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primaryColor,
          content: const Text(
            '🔕 Notification permission denied.',
            style: TextStyle(color: Colors.white),
          ),
          action: SnackBarAction(
            label: 'Open Settings',
            textColor: AppColors.whiteColor,
            backgroundColor: AppColors.backgroundDark,
            onPressed: () async {
              await openAndroidNotificationSettings();
            },
          ),
        ),
      );
    }
    return granted;
  }

  Future<void> openAndroidNotificationSettings() async {
    if (Platform.isAndroid) {
      final info = await PackageInfo.fromPlatform();

      final intent = AndroidIntent(
        action: 'android.settings.APP_NOTIFICATION_SETTINGS',
        arguments: {'android.provider.extra.APP_PACKAGE': info.packageName},
      );

      await intent.launch();
    }
  }

  Future<void> rescheduleAllReminders() async {
    final box = Hive.box<MedicationReminder>('medications');
    final notificationService = sl<NotificationService>();

    for (final reminder in box.values) {
      await notificationService.scheduleMedicationReminder(reminder);
    }
  }

  void toggleNotifications(bool value) async {
    if (value) {
      final granted = await _checkAndRequestNotificationPermission();
      if (!granted) return;
    }
    setState(() {
      isNotificationsEnabled = value;
      settingsBox.put('notifications_enabled', value);
    });
    final notificationService = sl<NotificationService>();
    if (value) {
      await rescheduleAllReminders();
      //await notificationService.showNotification(
      //  id: 0,
      // title: 'Notifications Enabled',
      // body: 'You will now receive reminders.',
      //);
    } else {
      await notificationService.cancelAllNotifications();
    }
  }

  void toggleDarkMode(bool value) {
    context.read<ThemeProvider>().toggleTheme(value);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text(
          "Settings",
          style: AppStyles.primaryHeadLinesStyle.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.settings, color: Colors.white, size: 30),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        shape: const CircleBorder(),
        onPressed: () async {
          final user = FirebaseAuth.instance.currentUser;

          if (user != null) {
            // await Hive.box('medications').clear();
            await FirebaseAuth.instance.signOut();
          }
          if (!context.mounted) return;
          GoRouter.of(context).go('/onboardingScreen');
        },
        child: Icon(
          FirebaseAuth.instance.currentUser != null
              ? Icons.logout
              : Icons.login,
          color: Colors.white,
          size: 28,
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 25),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Enable Notifications",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 20.sp,
                  ),
                ),
                Switch(
                  value: isNotificationsEnabled,
                  onChanged: toggleNotifications,
                  activeColor: AppColors.primaryColor,
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Dark Mode",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 20.sp,
                  ),
                ),
                Switch(
                  value:
                      context.watch<ThemeProvider>().themeMode ==
                      ThemeMode.dark,
                  onChanged: toggleDarkMode,
                  activeColor: AppColors.primaryColor,
                ),
              ],
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
