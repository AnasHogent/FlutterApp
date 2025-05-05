import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:med_reminder_app/core/styling/app_colors.dart';

class CustomIconButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String iconPath;
  const CustomIconButton({this.onTap, required this.iconPath, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 56.h,
        width: 105.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.primaryColor, width: 1),
          color: Colors.transparent,
        ),
        child: Center(
          child: SvgPicture.asset(iconPath, width: 12.w, height: 24.h),
        ),
      ),
    );
  }
}
