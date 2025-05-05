import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:med_reminder_app/core/styling/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String? hintText;
  final Widget? suffixIcon;
  final double? width;
  final bool? isPassword;
  const CustomTextField({
    super.key,
    this.hintText,
    this.suffixIcon,
    this.width,
    this.isPassword,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 331.w,
      child: TextFormField(
        autofocus: false,
        obscureText: isPassword ?? false,
        decoration: InputDecoration(
          hintText: hintText ?? "",
          contentPadding: EdgeInsets.symmetric(
            horizontal: 18.w,
            vertical: 18.h,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(color: Color(0xffE8ECF4), width: 1),
          ),
          filled: true,
          fillColor: Color(0xFFF7F8F9),
          hintStyle: TextStyle(
            fontSize: 15.sp,
            color: Color(0XFF8391A1),
            fontWeight: FontWeight.w400,
          ),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
