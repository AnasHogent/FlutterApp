import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        TextFormField(
          cursorColor: colorScheme.primary,
          controller: controller,
          validator: validator,
          autofocus: false,
          keyboardType: keyboardType,
          obscureText: isPassword ?? false,
          style: TextStyle(color: colorScheme.onSurface, fontSize: 15.sp),
          decoration: InputDecoration(
            hintText: title,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 18.w,
              vertical: 18.h,
            ),
            filled: true,
            fillColor: colorScheme.surface, // theme-based fill
            hintStyle: TextStyle(
              fontSize: 15.sp,
              color: colorScheme.onSurface.withAlpha(140), // subtiele hint
              fontWeight: FontWeight.w400,
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(
                color: colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: colorScheme.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: colorScheme.error, width: 1),
            ),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
