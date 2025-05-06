import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:med_reminder_app/core/routing/app_routes.dart';
import 'package:med_reminder_app/core/styling/app_colors.dart';
import 'package:med_reminder_app/core/styling/app_styles.dart';
import 'package:med_reminder_app/core/widgets/primary_button_widget.dart';
import 'package:med_reminder_app/screens/auth/cubit/auth_cubit.dart';
import 'package:med_reminder_app/screens/auth/cubit/auth_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        centerTitle: true,
        //automaticallyImplyLeading: false,
        title: Text(
          "Medication Reminder",
          style: AppStyles.primaryHeadLinesStyle.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthLoggedOut) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            GoRouter.of(context).go(AppRoutes.loginScreen);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.flag, size: 100),
              const SizedBox(height: 30),
              PrimaryButtonWidget(
                buttonText: "Logout",
                onPressed: () {
                  context.read<AuthCubit>().logout();
                },
              ),
              const SizedBox(height: 30),
              PrimaryButtonWidget(
                buttonText: "Add Medication",
                onPressed: () {
                  GoRouter.of(context).pushNamed(AppRoutes.addMedicationScreen);
                },
              ),
              const SizedBox(height: 30),
              PrimaryButtonWidget(
                buttonText: "Edit Medication",
                onPressed: () {
                  GoRouter.of(
                    context,
                  ).pushNamed(AppRoutes.editMedicationScreen);
                },
              ),
              const SizedBox(height: 30),
              PrimaryButtonWidget(
                buttonText: "Settings",
                onPressed: () {
                  GoRouter.of(context).pushNamed(AppRoutes.settingsScreen);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
