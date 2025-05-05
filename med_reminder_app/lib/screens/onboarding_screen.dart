import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:med_reminder_app/core/routing/app_routes.dart';
import 'package:med_reminder_app/core/styling/app_assets.dart';
import 'package:med_reminder_app/core/styling/app_styles.dart';
import 'package:med_reminder_app/core/widgets/primary_button_widget.dart';
import 'package:med_reminder_app/core/widgets/primary_outlined_button_widget.dart';
import 'package:med_reminder_app/core/widgets/spacing_widgates.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              AppAssets.onboard,
              width: double.infinity,
              height: 570.h,
              fit: BoxFit.fitWidth,
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
              onPressed: () {},
              buttonText: "Register",
              width: 331.w,
              height: 56.h,
            ),
            HeightSpace(46),
            Text(
              "Continue as a guest",
              style: AppStyles.black15BoldStyle.copyWith(
                color: const Color(0xFF202955),
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
