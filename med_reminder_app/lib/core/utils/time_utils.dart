import 'package:flutter/material.dart';

TimeOfDay? parseTimeOfDay(String timeStr) {
  final parts = timeStr.split(':');
  if (parts.length != 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;
  return TimeOfDay(hour: hour, minute: minute);
}
