import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:med_reminder_app/core/styling/app_colors.dart';
import 'package:med_reminder_app/core/styling/app_fonts.dart';
import 'package:med_reminder_app/core/styling/app_styles.dart';

class AppThemes {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.whiteColor,
    fontFamily: AppFonts.mainFontName,
    textTheme: TextTheme(
      titleLarge: AppStyles.primaryHeadLinesStyle,
      titleMedium: AppStyles.black15BoldStyle,
      bodyMedium: AppStyles.black16w500Style,
    ),
    dividerColor: AppColors.primaryColor,
    colorScheme: ColorScheme.light(
      primary: AppColors.primaryColor,
      onPrimary: AppColors.whiteColor,
      surface: AppColors.whiteColor,
      onSurface: AppColors.primaryColor,
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: AppColors.primaryColor,
      disabledColor: AppColors.secondaryColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.whiteColor,
      foregroundColor: AppColors.blackColor,
      elevation: 0,
      titleTextStyle: AppStyles.primaryHeadLinesStyle.copyWith(fontSize: 20.sp),
    ),
  );
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.blackColor,
    fontFamily: AppFonts.mainFontName,
    textTheme: TextTheme(
      titleLarge: AppStyles.primaryHeadLinesStyle.copyWith(
        color: AppColors.whiteColor,
      ),
      titleMedium: AppStyles.white15BoldStyle.copyWith(
        color: AppColors.whiteColor.withAlpha((255 * 0.8).round()),
      ),
      bodyMedium: AppStyles.white16w500Style,
    ),
    dividerColor: AppColors.greyColor,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryColor,
      onPrimary: AppColors.whiteColor,
      surface: AppColors.backgroundDark,
      onSurface: AppColors.whiteColor,
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: AppColors.primaryColor,
      disabledColor: AppColors.whiteColor.withAlpha((255 * 0.6).round()),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundDark,
      foregroundColor: AppColors.whiteColor,
      elevation: 0,
      titleTextStyle: AppStyles.primaryHeadLinesStyle.copyWith(
        fontSize: 20.sp,
        color: AppColors.whiteColor,
      ),
    ),
  );
}
