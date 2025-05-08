import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:med_reminder_app/core/styling/app_colors.dart';
import 'package:med_reminder_app/core/styling/app_styles.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Box settingsBox;
  bool isNotificationsEnabled = true;
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    settingsBox = Hive.box('settings');

    isNotificationsEnabled = settingsBox.get(
      'notifications_enabled',
      defaultValue: true,
    );
    isDarkMode = settingsBox.get('darkMode', defaultValue: false);
  }

  void toggleNotifications(bool value) {
    setState(() {
      isNotificationsEnabled = value;
      settingsBox.put('notifications_enabled', value);

      // if (!value) {
      //   flutterLocalNotificationsPlugin.cancelAll();
      // }
    });
  }

  void toggleDarkMode(bool value) {
    settingsBox.put('darkMode', value);
    setState(() {
      isDarkMode = value;
    });
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
                Text("Enable Notifications", style: AppStyles.black16w500Style),
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
                Text("Dark Mode", style: AppStyles.black16w500Style),
                Switch(
                  value: isDarkMode,
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
