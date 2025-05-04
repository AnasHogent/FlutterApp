import 'package:flutter/material.dart';
import 'package:med_reminder_app/core/styling/app_colors.dart';
import 'package:med_reminder_app/core/styling/app_fonts.dart';
import 'package:med_reminder_app/core/styling/app_styles.dart';

class AppThemes {
  static final lightTheme = ThemeData(
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.whiteColor,
    fontFamily: AppFonts.mainFontName,
    textTheme: TextTheme(
      titleLarge: AppStyles.primaryHeadLinesStyle,
      titleMedium: AppStyles.subtitlesStyle,
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: AppColors.primaryColor,
      disabledColor: AppColors.secondaryColor,
    ),
  );
}
