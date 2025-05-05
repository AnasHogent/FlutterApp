import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:med_reminder_app/core/routing/app_routes.dart';
import 'package:med_reminder_app/core/styling/app_colors.dart';
import 'package:med_reminder_app/core/styling/app_styles.dart';
import 'package:med_reminder_app/core/widgets/custom_text_field.dart';
import 'package:med_reminder_app/core/widgets/primary_button_widget.dart';
import 'package:med_reminder_app/core/widgets/spacing_widgates.dart';
import 'package:med_reminder_app/screens/auth/repo/auth_repo.dart';
import 'package:med_reminder_app/screens/auth/widgates/back_button_widgate.dart';
import 'package:med_reminder_app/screens/auth/widgates/custom_or_login_widgate.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool isPassword = true;
  final formKey = GlobalKey<FormState>();
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController password;
  late TextEditingController confirmPassword;
  Future<void> registerUser() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: password.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account created successfully")),
      );

      GoRouter.of(context).go('/home');
    } on FirebaseAuthException catch (e) {
      String errorMsg;
      if (e.code == 'email-already-in-use') {
        errorMsg = 'This email is already in use';
      } else if (e.code == 'weak-password') {
        errorMsg = 'The password is too weak';
      } else {
        errorMsg = e.message ?? 'Registration failed';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMsg)));
    }
  }

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    password = TextEditingController();
    confirmPassword = TextEditingController();
    usernameController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Form(
              key: formKey,
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
                      "Hello! Register to get started",
                      style: AppStyles.primaryHeadLinesStyle,
                    ),
                  ),
                  const HeightSpace(32),
                  CustomTextField(
                    hintText: "Username",
                    controller: usernameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Enter your Username";
                      }
                      if (value.length < 4) {
                        return "Username must be at least 4 characters";
                      }
                      return null;
                    },
                  ),
                  const HeightSpace(15),
                  CustomTextField(
                    hintText: "Email",
                    controller: emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Enter your email";
                      }
                      if (!RegExp(
                        r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
                      ).hasMatch(value)) {
                        return "Enter a valid email address";
                      }
                      return null;
                    },
                  ),
                  const HeightSpace(15),
                  CustomTextField(
                    controller: password,
                    hintText: "Password",
                    isPassword: isPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Enter your password";
                      }
                      if (value.length < 8) {
                        return "Password must be at least 8 characters";
                      }
                      return null;
                    },
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
                  CustomTextField(
                    controller: confirmPassword,
                    hintText: "Confirm Password",
                    isPassword: isPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Confirm your password";
                      }
                      if (value != password.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),
                  const HeightSpace(15),
                  PrimaryButtonWidget(
                    buttonText: "Register",
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        final result = await AuthRepo().registerUser(
                          username: usernameController.text.trim(),
                          email: emailController.text.trim(),
                          password: password.text.trim(),
                        );

                        result.fold(
                          (error) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(error)));
                          },
                          (successMessage) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(successMessage)),
                            );
                            GoRouter.of(
                              context,
                            ).pushNamed(AppRoutes.loginScreen);
                          },
                        );
                      }
                    },
                  ),
                  HeightSpace(35),
                  Row(
                    children: [
                      SizedBox(width: 92.w, child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: Text(
                          "Or Register With",
                          style: AppStyles.black15BoldStyle.copyWith(
                            color: const Color(0xFF6A707C),
                          ),
                        ),
                      ),
                      SizedBox(width: 92.w, child: Divider()),
                    ],
                  ),
                  const HeightSpace(22),
                  const CustomOrLoginWidgate(),
                  const HeightSpace(20),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: "Already have an account? ",
                        style: AppStyles.black15BoldStyle,
                        children: [
                          TextSpan(
                            text: "Login Now",
                            style: AppStyles.black16w500Style.copyWith(
                              color: AppColors.primaryColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer:
                                TapGestureRecognizer()
                                  ..onTap = () {
                                    GoRouter.of(
                                      context,
                                    ).pushNamed(AppRoutes.loginScreen);
                                  },
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
      ),
    );
  }
}
