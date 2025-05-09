import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:med_reminder_app/core/di/dependency_injection.dart';
import 'package:med_reminder_app/core/routing/app_routes.dart';
import 'package:med_reminder_app/models/medication_reminder.dart';
import 'package:med_reminder_app/screens/add/add_medication_screen.dart';
import 'package:med_reminder_app/screens/auth/cubit/auth_cubit.dart';
import 'package:med_reminder_app/screens/auth/forget_password_screen.dart';
import 'package:med_reminder_app/screens/auth/login_screen.dart';
import 'package:med_reminder_app/screens/auth/register_screen.dart';
import 'package:med_reminder_app/screens/edit/edit_medication_screen.dart';
import 'package:med_reminder_app/screens/home/home_screen.dart';
import 'package:med_reminder_app/screens/onboarding_screen.dart';
import 'package:med_reminder_app/screens/sittings/settings_screen.dart';

class RouterGenerationCongig {
  static final Box settingsBox = Hive.box('settings');

  static String _getInitialRoute() {
    final hasSeenOnboarding = settingsBox.get(
      'seen_onboarding',
      defaultValue: false,
    );
    final isGuest = settingsBox.get('is_guest', defaultValue: false);
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;

    if (isLoggedIn || isGuest) {
      return AppRoutes.homeScreen;
    } else if (!hasSeenOnboarding) {
      return AppRoutes.onboardingScreen;
    } else {
      return AppRoutes.loginScreen;
    }
  }

  static final GoRouter goRouter = GoRouter(
    initialLocation: _getInitialRoute(),
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
      GoRoute(
        path: AppRoutes.addMedicationScreen,
        name: AppRoutes.addMedicationScreen,
        builder: (context, state) => const AddMedicationScreen(),
      ),
      GoRoute(
        path: AppRoutes.editMedicationScreen,
        name: AppRoutes.editMedicationScreen,
        builder: (context, state) {
          final med = state.extra as MedicationReminder;
          return EditMedicationScreen(reminder: med);
        },
      ),
      GoRoute(
        path: AppRoutes.settingsScreen,
        name: AppRoutes.settingsScreen,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
