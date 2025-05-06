import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:med_reminder_app/core/di/dependency_injection.dart';
import 'package:med_reminder_app/core/routing/app_routes.dart';
import 'package:med_reminder_app/screens/auth/cubit/auth_cubit.dart';
import 'package:med_reminder_app/screens/auth/forget_password_screen.dart';
import 'package:med_reminder_app/screens/auth/login_screen.dart';
import 'package:med_reminder_app/screens/auth/register_screen.dart';
import 'package:med_reminder_app/screens/home/home_screen.dart';
import 'package:med_reminder_app/screens/onboarding_screen.dart';

class RouterGenerationCongig {
  static GoRouter goRouter = GoRouter(
    initialLocation: AppRoutes.onboardingScreen,
    routes: [
      GoRoute(
        path: AppRoutes.onboardingScreen,
        name: AppRoutes.onboardingScreen,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.loginScreen,
        name: AppRoutes.loginScreen,
        builder:
            (context, state) => BlocProvider(
              create: (context) => sl<AuthCubit>(),
              child: const LoginScreen(),
            ),
      ),
      GoRoute(
        path: AppRoutes.registerScreen,
        name: AppRoutes.registerScreen,
        builder:
            (context, state) => BlocProvider(
              create: (context) => sl<AuthCubit>(),
              child: const RegisterScreen(),
            ),
      ),
      GoRoute(
        path: AppRoutes.forgetPasswordScreen,
        name: AppRoutes.forgetPasswordScreen,
        builder:
            (context, state) => BlocProvider.value(
              value: sl<AuthCubit>(),
              child: const ForgetPasswordScreen(),
            ),
      ),

      GoRoute(
        path: AppRoutes.homeScreen,
        name: AppRoutes.homeScreen,
        builder:
            (context, state) => BlocProvider.value(
              value: sl<AuthCubit>(),
              child: const HomeScreen(),
            ),
      ),
    ],
  );
}
