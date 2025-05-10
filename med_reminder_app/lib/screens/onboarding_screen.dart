import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:med_reminder_app/core/routing/app_routes.dart';
import 'package:med_reminder_app/core/styling/app_assets.dart';
import 'package:med_reminder_app/core/widgets/buttons/primary_button_widget.dart';
import 'package:med_reminder_app/core/widgets/buttons/primary_outlined_button_widget.dart';
import 'package:med_reminder_app/core/widgets/spacing_widgates.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    return Scaffold(
      body: SafeArea(
        bottom: true,
        top: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                AppAssets.onboard,
                width: double.infinity,
                height: 570.h,
                fit: BoxFit.fill,
              ),
              HeightSpace(21),
              PrimaryButtonWidget(
                onPressed: () {
                  GoRouter.of(context).pushNamed(AppRoutes.loginScreen);
                },
                buttonText: "Login",
                width: 331.w,
                height: 56.h,
              ),
              HeightSpace(15),
              PrimaryOutlinedButtonWidget(
                onPressed: () {
                  GoRouter.of(context).pushNamed(AppRoutes.registerScreen);
                },
                buttonText: "Register",
                width: 331.w,
                height: 56.h,
              ),
              HeightSpace(20),
              InkWell(
                onTap: () async {
                  await Hive.box('settings').put('is_logged_in', false);
                  await Hive.box('settings').put('is_guest', true);
                  if (!context.mounted) return;
                  GoRouter.of(context).replaceNamed(AppRoutes.homeScreen);
                },
                child: Text(
                  "Continue as a guest",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
