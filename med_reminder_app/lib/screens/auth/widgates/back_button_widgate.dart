import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:med_reminder_app/core/styling/app_colors.dart';

class BackButtonWidgate extends StatelessWidget {
  const BackButtonWidgate({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 41.h,
      width: 41.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primaryColor, width: 1),
        color: Colors.transparent,
      ),
      child: Center(
        child: IconButton(
          onPressed: () {
            GoRouter.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios_new),
          color: AppColors.primaryColor,
        ),
      ),
    );
  }
}
