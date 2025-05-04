import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:med_reminder_app/core/styling/app_colors.dart';

class PrimaryOutlinedButtonWidget extends StatelessWidget {
  final String? buttonText;
  final Color? borderColor;
  final double? width;
  final double? height;
  final double? fontSize;
  final Color? textColor;
  final void Function()? onPressed;
  final double? bordersRadius;

  const PrimaryOutlinedButtonWidget({
    super.key,
    this.buttonText,
    this.borderColor,
    this.width,
    this.height,
    this.textColor,
    this.onPressed,
    this.bordersRadius,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: borderColor ?? AppColors.primaryColor,
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(bordersRadius ?? 8.r),
        ),
        fixedSize: Size(width ?? 331.w, height ?? 56.h),
      ),
      child: Text(
        buttonText ?? "",
        style: TextStyle(
          color: textColor ?? AppColors.primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: fontSize ?? 20.sp,
        ),
      ),
    );
  }
}
