import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:med_reminder_app/core/routing/app_routes.dart';
import 'package:med_reminder_app/core/styling/app_assets.dart';
import 'package:med_reminder_app/core/styling/app_colors.dart';
import 'package:med_reminder_app/core/styling/app_styles.dart';
import 'package:med_reminder_app/core/widgets/spacing_widgates.dart';
import 'package:med_reminder_app/models/medication_reminder.dart';
import 'package:med_reminder_app/screens/auth/cubit/auth_cubit.dart';
import 'package:med_reminder_app/screens/auth/cubit/auth_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white, size: 30),
            onPressed: () {
              GoRouter.of(context).pushNamed(AppRoutes.settingsScreen);
            },
          ),
        ],

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
      floatingActionButton: SizedBox(
        height: 60,
        width: 60,
        child: FloatingActionButton(
          shape: const CircleBorder(),
          backgroundColor: AppColors.primaryColor,
          elevation: 5,
          child: Icon(Icons.add, color: AppColors.whiteColor, size: 30),
          onPressed: () {
            GoRouter.of(context).pushNamed(AppRoutes.addMedicationScreen);
          },
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
        child: ValueListenableBuilder<Box<MedicationReminder>>(
          valueListenable:
              Hive.box<MedicationReminder>('medications').listenable(),
          builder: (context, Box<MedicationReminder> box, _) {
            final meds = box.values.toList();
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                ...meds.map(
                  (med) => GestureDetector(
                    onTap: () {
                      GoRouter.of(
                        context,
                      ).pushNamed(AppRoutes.editMedicationScreen, extra: med);
                    },
                    child: Card(
                      color: AppColors.whiteColor,
                      shadowColor: AppColors.primaryColor,
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SvgPicture.asset(
                                  AppAssets.medicineSVGIcon,
                                  height: 60.h,
                                  width: 60.w,
                                  fit: BoxFit.contain,
                                ),
                                const WidthSpace(30),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const HeightSpace(6),
                                      Text(
                                        med.name,
                                        style: AppStyles.black16w500Style
                                            .copyWith(fontSize: 25),
                                      ),
                                      const HeightSpace(6),
                                      Text(
                                        "Start: ${med.startDate.toString().split(' ')[0]}",
                                        style: AppStyles.black15BoldStyle
                                            .copyWith(color: Colors.grey[700]),
                                      ),
                                      const HeightSpace(3),
                                      Text(
                                        "End:   ${med.endDate != null ? med.endDate!.toString().split(' ')[0] : 'N/A'}",
                                        style: AppStyles.black15BoldStyle
                                            .copyWith(color: Colors.grey[700]),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const HeightSpace(6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children:
                                  med.times.map((time) {
                                    return Chip(
                                      label: Text(time),
                                      backgroundColor: AppColors.primaryColor
                                          .withAlpha((255 * 0.5).round()),
                                      labelStyle: AppStyles.black15BoldStyle
                                          .copyWith(fontSize: 18),
                                    );
                                  }).toList(),
                            ),
                            const HeightSpace(6),
                            Text(
                              "Repeat every: ${med.repeatDays} day(s)",
                              style: AppStyles.black15BoldStyle.copyWith(
                                color: Colors.grey[700],
                              ),
                            ),
                            const HeightSpace(6),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const HeightSpace(30),
              ],
            );
          },
        ),
      ),
    );
  }
}
