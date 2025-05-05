import 'package:go_router/go_router.dart';
import 'package:med_reminder_app/core/routing/app_routes.dart';
import 'package:med_reminder_app/screens/auth/login_screen.dart';
import 'package:med_reminder_app/screens/auth/register_screen.dart';
import 'package:med_reminder_app/screens/onboarding_screen.dart';

import '../../screens/auth/forget_password_screen.dart';

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
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.registerScreen,
        name: AppRoutes.registerScreen,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgetPasswordScreen,
        name: AppRoutes.forgetPasswordScreen,
        builder: (context, state) => const ForgetPasswordScreen(),
      ),
    ],
  );
}
