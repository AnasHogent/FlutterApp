import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:med_reminder_app/core/services/notification_service.dart';
import 'package:med_reminder_app/core/services/sync_service.dart';
import 'package:med_reminder_app/core/styling/app_colors.dart';
import 'package:med_reminder_app/core/styling/app_styles.dart';
import 'package:med_reminder_app/core/theme/theme_provider.dart';
import 'package:med_reminder_app/core/widgets/buttons/primary_button_widget.dart';
import 'package:med_reminder_app/core/widgets/spacing_widgates.dart';
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
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    settingsBox = Hive.box('settings');
    isNotificationsEnabled = settingsBox.get(
      'notifications_enabled',
      defaultValue: false,
    );
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    _packageInfo = await PackageInfo.fromPlatform();
  }

  Future<void> toggleNotifications(bool value) async {
    final notificationService = sl<NotificationService>();

    if (value) {
      final granted = await _checkAndRequestNotificationPermission();
      if (!granted) return;

      final exactGranted = await _checkAndRequestExactAlarmPermission();
      if (!exactGranted) return;
    }

    await settingsBox.put('notifications_enabled', value);
    setState(() => isNotificationsEnabled = value);

    if (value) {
      await rescheduleAllReminders();
    } else {
      await notificationService.cancelAllNotifications();
    }
  }

  Future<void> toggleDarkMode(bool value) async {
    context.read<ThemeProvider>().toggleTheme(value);
    setState(() {});
  }

  Future<void> rescheduleAllReminders() async {
    final reminders = Hive.box<MedicationReminder>('medications').values;
    final notificationService = sl<NotificationService>();

    for (final reminder in reminders) {
      await notificationService.scheduleMedicationReminder(reminder);
    }
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
            style: TextStyle(color: AppColors.whiteColor),
          ),
          action: SnackBarAction(
            label: 'Open Settings',
            textColor: AppColors.whiteColor,
            backgroundColor: AppColors.backgroundDark,
            onPressed: () => _openNotificationSettings(),
          ),
        ),
      );
    }

    return granted;
  }

  Future<void> _openNotificationSettings() async {
    if (Platform.isAndroid && _packageInfo != null) {
      final intent = AndroidIntent(
        action: 'android.settings.APP_NOTIFICATION_SETTINGS',
        arguments: {
          'android.provider.extra.APP_PACKAGE': _packageInfo!.packageName,
        },
      );
      await intent.launch();
    }
  }

  Future<void> _handleLogout() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await FirebaseAuth.instance.signOut();
      await Hive.box<MedicationReminder>('medications').clear();

      final notificationService = sl<NotificationService>();
      await notificationService.cancelAllNotifications();

      if (!mounted) return;
      context.go('/onboardingScreen');
    } else {
      context.go('/loginScreen');
    }
  }

  Future<bool> _checkAndRequestExactAlarmPermission() async {
    final notificationService = sl<NotificationService>();
    final granted = await notificationService.hasExactAlarmPermission();

    if (!granted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primaryColor,
          content: const Text(
            '⏰ Exact alarm permission required to schedule reminders.',
            style: TextStyle(color: AppColors.whiteColor),
          ),
          action: SnackBarAction(
            label: 'Open Settings',
            textColor: AppColors.whiteColor,
            backgroundColor: AppColors.backgroundDark,
            onPressed: () => _openExactAlarmSettings(),
          ),
        ),
      );
    }

    return granted;
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        context.watch<ThemeProvider>().themeMode == ThemeMode.dark;

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
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.settings, color: Colors.white, size: 30),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor:
            FirebaseAuth.instance.currentUser != null
                ? Colors.red
                : AppColors.primaryColor,
        shape: const CircleBorder(),
        onPressed: _handleLogout,
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
            _buildSwitchRow(
              label: "Enable Notifications",
              value: isNotificationsEnabled,
              onChanged: toggleNotifications,
            ),
            const Divider(),
            _buildSwitchRow(
              label: "Dark Mode",
              value: isDarkMode,
              onChanged: toggleDarkMode,
            ),
            const Divider(),
            HeightSpace(10),
            PrimaryButtonWidget(
              buttonText: 'Sync Data',
              onPressed: () async {
                final syncService = sl<SyncService>();
                final hasNet = await syncService.hasInternet();

                final uid = FirebaseAuth.instance.currentUser?.uid;
                if (!hasNet) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'No internet connection. Sync failed.',
                          style: TextStyle(color: AppColors.whiteColor),
                        ),
                        backgroundColor: AppColors.primaryColor,
                      ),
                    );
                  }
                }

                if (uid == null) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please login first. Sync failed.',
                          style: TextStyle(color: AppColors.whiteColor),
                        ),
                        backgroundColor: AppColors.primaryColor,
                      ),
                    );
                  }
                  return;
                }

                await syncService.syncAllPending();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Synchronization completed successfully.',
                        style: TextStyle(color: AppColors.whiteColor),
                      ),
                      backgroundColor: AppColors.primaryColor,
                    ),
                  );
                  if (Navigator.of(context).canPop()) {
                    context.pop();
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchRow({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 20.sp,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primaryColor,
        ),
      ],
    );
  }
}
