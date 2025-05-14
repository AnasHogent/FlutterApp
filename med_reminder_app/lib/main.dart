import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:med_reminder_app/core/di/dependency_injection.dart';
import 'package:med_reminder_app/core/routing/router_generation_congig.dart';
import 'package:med_reminder_app/core/services/background_sync.dart';
import 'package:med_reminder_app/core/services/init_hive.dart';
import 'package:med_reminder_app/core/services/notification_service.dart';
import 'package:med_reminder_app/core/styling/theme_data.dart';
import 'package:med_reminder_app/core/theme/theme_provider.dart';
import 'package:med_reminder_app/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await initHive();

  tz.initializeTimeZones();
  final String localTimeZone = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(localTimeZone));

  await AndroidAlarmManager.initialize();
  await scheduleDailyBackgroundSync();

  await initDI();

  await sl<NotificationService>().getPendingNotifications();
  //await sl<UserSessionService>().restoreSession();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //final themeProvider = Provider.of<ThemeProvider>(context);
    final themeProvider = context.watch<ThemeProvider>();
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Med Reminder',
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          //themeMode: ThemeMode.system,
          themeMode: themeProvider.themeMode,
          routerConfig: RouterGenerationCongig.goRouter,
        );
      },
    );
  }
}
