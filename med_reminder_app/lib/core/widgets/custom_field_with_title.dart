import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:med_reminder_app/core/styling/app_colors.dart';
import 'package:med_reminder_app/core/styling/app_styles.dart';

class CustomFieldWithTitle extends StatelessWidget {
  final String title;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool? isPassword;
  final Widget? suffixIcon;
  final double? width;

  const CustomFieldWithTitle({
    super.key,
    required this.title,
    this.controller,
    this.validator,
    this.keyboardType,
    this.isPassword,
    this.suffixIcon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppStyles.black16w500Style),
        TextFormField(
          cursorColor: AppColors.primaryColor,
          controller: controller,
          validator: validator,
          autofocus: false,
          keyboardType: keyboardType,
          obscureText: isPassword ?? false,
          decoration: InputDecoration(
            hintText: title,
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.red, width: 1),
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
      ],
    );
  }
}
