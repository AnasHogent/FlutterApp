import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:med_reminder_app/core/routing/app_routes.dart';
import 'package:med_reminder_app/core/styling/app_colors.dart';
import 'package:med_reminder_app/core/styling/app_styles.dart';
import 'package:med_reminder_app/core/widgets/buttons/primary_button_widget.dart';
import 'package:med_reminder_app/core/widgets/custom_text_field.dart';
import 'package:med_reminder_app/core/widgets/spacing_widgates.dart';
import 'package:med_reminder_app/screens/auth/cubit/auth_cubit.dart';
import 'package:med_reminder_app/screens/auth/cubit/auth_state.dart';
import 'package:med_reminder_app/screens/auth/widgates/back_button_widgate.dart';
import 'package:med_reminder_app/screens/auth/widgates/custom_or_login_widgate.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isPassword = true;
  final formKey = GlobalKey<FormState>();
  late TextEditingController emailController;
  late TextEditingController password;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    password = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) async {
              if (state is AuthSuccess) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
                await Hive.box('settings').put('is_logged_in', true);
                await Hive.box('settings').put('is_guest', false);
                if (!context.mounted) return;
                GoRouter.of(context).go(AppRoutes.homeScreen);
                password.clear();
              } else if (state is AuthError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
            builder: (context, state) {
              if (state is AuthLoading) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return Padding(
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
                          "Welcome Back Again",
                          style: AppStyles.primaryHeadLinesStyle,
                        ),
                      ),
                      const HeightSpace(32),
                      CustomTextField(
                        hintText: "Enter Your Email",
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
                        hintText: "Enter Your Password",
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
                      PrimaryButtonWidget(
                        buttonText: "Login",
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            context.read<AuthCubit>().login(
                              email: emailController.text.trim(),
                              password: password.text.trim(),
                            );
                          }
                        },
                      ),
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
                      const HeightSpace(90),
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
                                recognizer:
                                    TapGestureRecognizer()
                                      ..onTap = () {
                                        GoRouter.of(
                                          context,
                                        ).pushNamed(AppRoutes.registerScreen);
                                      },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
