import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:med_reminder_app/core/routing/router_generation_congig.dart';
import 'package:med_reminder_app/core/styling/theme_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Flutter Demo',
          theme: AppThemes.lightTheme,
          routerConfig: RouterGenerationCongig.goRouter,
        );
      },
    );
  }
}
