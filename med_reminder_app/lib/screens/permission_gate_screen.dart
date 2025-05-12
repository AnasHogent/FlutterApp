import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:med_reminder_app/core/routing/app_routes.dart';
import 'package:med_reminder_app/core/services/notification_service.dart';
import 'package:med_reminder_app/core/styling/app_assets.dart';
import 'package:med_reminder_app/core/styling/app_styles.dart';
import 'package:med_reminder_app/core/widgets/buttons/primary_button_widget.dart';
import 'package:med_reminder_app/core/widgets/buttons/primary_outlined_button_widget.dart';
import 'package:med_reminder_app/core/widgets/spacing_widgates.dart';
import 'package:package_info_plus/package_info_plus.dart';

final sl = GetIt.instance;

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  bool notificationGranted = false;
  bool exactAlarmGranted = false;

  Future<void> requestNotificationPermission() async {
    final granted = await sl<NotificationService>().requestPermissionIfNeeded();
    setState(() {
      notificationGranted = granted;
    });

    if (granted) {
      await Hive.box('settings').put('notifications_granted', true);
    } else {
      _showSnackBar(
        '🔕 Notification permission denied.',
        _openNotificationSettings,
      );
    }
  }

  Future<void> requestExactAlarmPermission() async {
    final granted = await sl<NotificationService>().hasExactAlarmPermission();
    setState(() {
      exactAlarmGranted = granted;
    });

    if (granted) {
      await Hive.box('settings').put('exact_alarm_granted', true);
    } else {
      _showSnackBar(
        '⏰ Exact alarm permission required.',
        _openExactAlarmSettings,
      );
    }
  }

  void _showSnackBar(String message, VoidCallback onPressed) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black87,
        action: SnackBarAction(
          label: 'Settings',
          textColor: Colors.white,
          onPressed: onPressed,
        ),
      ),
    );
  }

  Future<void> _openNotificationSettings() async {
    if (Platform.isAndroid) {
      final info = await PackageInfo.fromPlatform();
      try {
        final intent = AndroidIntent(
          action: 'android.settings.APP_NOTIFICATION_SETTINGS',
          arguments: {
            'android.provider.extra.APP_PACKAGE': info.packageName,
            'app_package': info.packageName,
          },
        );
        await intent.launch();
      } catch (_) {
        final fallbackIntent = AndroidIntent(
          action: 'android.settings.APPLICATION_DETAILS_SETTINGS',
          data: 'package:${info.packageName}',
        );
        await fallbackIntent.launch();
      }
    }
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
    return Scaffold(
      body: SafeArea(
        bottom: true,
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                AppAssets.onboard,
                width: double.infinity,
                height: 520.h,
                fit: BoxFit.fill,
              ),
              HeightSpace(5),

              Text(
                (notificationGranted && exactAlarmGranted)
                    ? "Thank you! now continue"
                    : "To ensure the app works properly,\nplease grant the following permissions:",
                style: AppStyles.white16w500Style.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              HeightSpace(10),
              PrimaryOutlinedButtonWidget(
                buttonText: "Notification Permission",
                onPressed: requestNotificationPermission,
              ),
              HeightSpace(15),
              PrimaryOutlinedButtonWidget(
                buttonText: "Exact Alarm Permission",
                onPressed: requestExactAlarmPermission,
              ),
              HeightSpace(20),
              PrimaryButtonWidget(
                buttonText: "Continue",
                onPressed:
                    (notificationGranted && exactAlarmGranted)
                        ? () => context.goNamed(AppRoutes.onboardingScreen)
                        : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
