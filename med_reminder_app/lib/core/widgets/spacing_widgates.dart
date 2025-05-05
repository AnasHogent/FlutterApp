import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WidthSpace extends StatelessWidget {
  final double width;
  const WidthSpace(this.width, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width ?? 20.w);
  }
}

class HeightSpace extends StatelessWidget {
  final double height;
  const HeightSpace(this.height, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height ?? 20.h);
  }
}
