import 'package:flutter/material.dart';
import 'package:med_reminder_app/core/styling/app_assets.dart';
import 'package:med_reminder_app/screens/auth/widgates/custom_icon_button.dart';

class CustomOrLoginWidgate extends StatelessWidget {
  const CustomOrLoginWidgate({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomIconButton(iconPath: AppAssets.facebookSVGIcon, onTap: () {}),
        CustomIconButton(iconPath: AppAssets.googleSVGIcon, onTap: () {}),
        CustomIconButton(iconPath: AppAssets.appleSVGIcon, onTap: () {}),
      ],
    );
  }
}
