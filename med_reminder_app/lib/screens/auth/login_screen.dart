import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:med_reminder_app/core/styling/app_colors.dart';
import 'package:med_reminder_app/core/styling/app_styles.dart';
import 'package:med_reminder_app/core/widgets/custom_text_field.dart';
import 'package:med_reminder_app/core/widgets/primary_button_widget.dart';
import 'package:med_reminder_app/core/widgets/spacing_widgates.dart';
import 'package:med_reminder_app/screens/auth/widgates/back_button_widgate.dart';
import 'package:med_reminder_app/screens/auth/widgates/custom_or_login_widgate.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isPassword = true;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeightSpace(12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: BackButtonWidgate(),
                ),
                const HeightSpace(28),
                SizedBox(
                  width: 280.w,
                  child: Text(
                    "Welcome Back Again",
                    style: AppStyles.primaryHeadLinesStyle,
                  ),
                ),
                const HeightSpace(32),
                CustomTextField(hintText: "Enter Your Email"),
                const HeightSpace(15),
                CustomTextField(
                  hintText: "Enter Your Password",
                  isPassword: isPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPassword
                          ? Icons.remove_red_eye_outlined
                          : Icons.remove_red_eye,
                      size: 25.sp,
                      color: AppColors.primaryColor,
                    ),
                    onPressed: () {
                      setState(() {
                        isPassword = !isPassword;
                      });
                    },
                  ),
                ),
                const HeightSpace(15),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Forget Password?",
                    style: AppStyles.black15BoldStyle.copyWith(
                      color: Color(0xFF6A707C),
                    ),
                  ),
                ),
                const HeightSpace(30),
                PrimaryButtonWidget(buttonText: "Login", onPressed: () {}),
                HeightSpace(35),
                Row(
                  children: [
                    SizedBox(width: 105.w, child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Text(
                        "Or Login With",
                        style: AppStyles.black15BoldStyle.copyWith(
                          color: const Color(0xFF6A707C),
                        ),
                      ),
                    ),
                    SizedBox(width: 105.w, child: Divider()),
                  ],
                ),
                const HeightSpace(22),
                const CustomOrLoginWidgate(),
                const HeightSpace(120),
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: AppStyles.black15BoldStyle,
                      children: [
                        TextSpan(
                          text: "Register now",
                          style: AppStyles.black16w500Style.copyWith(
                            color: AppColors.primaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
