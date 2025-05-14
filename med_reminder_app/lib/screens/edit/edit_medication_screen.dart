import 'package:flutter/material.dart';
import 'package:med_reminder_app/core/di/dependency_injection.dart';
import 'package:med_reminder_app/core/services/notification_service.dart';
import 'package:med_reminder_app/core/services/sync_service.dart';
import 'package:med_reminder_app/core/styling/app_colors.dart';
import 'package:med_reminder_app/core/styling/app_styles.dart';
import 'package:med_reminder_app/core/widgets/buttons/primary_button_widget.dart';
import 'package:med_reminder_app/core/widgets/buttons/primary_outlined_button_widget.dart';
import 'package:med_reminder_app/core/widgets/custom_field_with_title.dart';
import 'package:med_reminder_app/core/widgets/custom_text_field.dart';
import 'package:med_reminder_app/core/widgets/spacing_widgates.dart';
import 'package:med_reminder_app/models/medication_reminder.dart';

final notificationService = sl<NotificationService>();

class EditMedicationScreen extends StatefulWidget {
  final MedicationReminder reminder;
  const EditMedicationScreen({super.key, required this.reminder});

  @override
  State<EditMedicationScreen> createState() => _EditMedicationScreenState();
}

class _EditMedicationScreenState extends State<EditMedicationScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController medicationNameController =
      TextEditingController();
  final TextEditingController repeatController = TextEditingController(
    text: '1',
  );

  final List<TimeOfDay> times = [];
  DateTime? startDate;
  DateTime? endDate;
  int repeatEveryXDays = 1;
  final bool isSynced = false;

  Future<void> _pickTime() async {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme:
                isDark
                    ? ColorScheme.dark(
                      primary: colorScheme.primary,
                      onPrimary: colorScheme.onPrimary,
                      surface: colorScheme.surface,
                      onSurface: colorScheme.onSurface,
                    )
                    : ColorScheme.light(
                      primary: colorScheme.primary,
                      onPrimary: colorScheme.onPrimary,
                      surface: colorScheme.surface,
                      onSurface: colorScheme.onSurface,
                    ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
            ),
          ),

          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() {
        times.add(time);
      });
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme:
                isDark
                    ? ColorScheme.dark(
                      primary: scheme.primary,
                      onPrimary: scheme.onPrimary,
                      surface: scheme.surface,
                      onSurface: scheme.onSurface,
                    )
                    : ColorScheme.light(
                      primary: scheme.primary,
                      onPrimary: scheme.onPrimary,
                      surface: scheme.surface,
                      onSurface: scheme.onSurface,
                    ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: scheme.primary),
            ),
          ),

          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        isStart ? startDate = date : endDate = date;
      });
    }
  }

  void _submit() async {
    repeatEveryXDays = int.tryParse(repeatController.text.trim()) ?? 1;
    if (formKey.currentState!.validate()) {
      if (times.isEmpty || startDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please select at least one time and a start date.',
              style: TextStyle(color: AppColors.whiteColor),
            ),
            backgroundColor: AppColors.primaryColor,
          ),
        );
        return;
      }
    }
    final oldTimes = List<String>.from(widget.reminder.times);

    final updatedReminder =
        widget.reminder
          ..name = medicationNameController.text.trim()
          ..times =
              times
                  .map(
                    (t) =>
                        "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}",
                  )
                  .toList()
          ..startDate = startDate!
          ..endDate = endDate
          ..repeatDays = repeatEveryXDays
          ..isSynced = false;

    // Hive propleem
    await notificationService.updateReminder(updatedReminder, oldTimes);
    await sl<SyncService>().trySyncOne(updatedReminder);
    await updatedReminder.save();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Medication updated',
          style: TextStyle(color: AppColors.whiteColor),
        ),
        backgroundColor: AppColors.primaryColor,
      ),
    );

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _delete() async {
    await notificationService.cancelReminder(widget.reminder);
    await sl<SyncService>().deleteReminder(widget.reminder.id);
    await widget.reminder.delete();
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    final reminder = widget.reminder;
    medicationNameController.text = reminder.name;
    repeatController.text = reminder.repeatDays.toString();
    times.addAll(
      reminder.times.map((t) {
        final parts = t.split(":");
        if (parts.length != 2) return null;

        final hour = int.tryParse(parts[0].trim());
        final minute = int.tryParse(parts[1].trim());

        if (hour == null || minute == null) return null;

        return TimeOfDay(hour: hour, minute: minute);
      }).whereType<TimeOfDay>(),
    );

    startDate = reminder.startDate;
    endDate = reminder.endDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Edit Medication",
          style: AppStyles.primaryHeadLinesStyle.copyWith(
            color: AppColors.whiteColor,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      //backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 3),
          child: Form(
            key: formKey,
            child: ListView(
              children: [
                Text(
                  "Medication name:",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                CustomTextField(
                  controller: medicationNameController,
                  hintText: "Medication name",
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'This field is required'
                              : null,
                ),
                const HeightSpace(16),
                Divider(),
                const HeightSpace(16),
                PrimaryButtonWidget(
                  onPressed: _pickTime,
                  buttonText: "Add time(s)",
                  width: 40,
                ),
                const HeightSpace(10),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children:
                      times
                          .asMap()
                          .entries
                          .map(
                            (entry) => Chip(
                              backgroundColor: Color(0xFFF7F8F9),
                              label: Text(
                                entry.value.format(context),
                                style: AppStyles.black15BoldStyle,
                              ),
                              deleteIcon: const Icon(
                                Icons.close,
                                size: 18,
                                color: Colors.red,
                              ),
                              onDeleted: () {
                                setState(() {
                                  times.removeAt(entry.key);
                                });
                              },
                            ),
                          )
                          .toList(),
                ),
                Divider(),
                ListTile(
                  title: Text(
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(fontSize: 25),
                    startDate == null
                        ? "Select start date"
                        : "Start:  ${startDate!.toLocal().toString().split(' ')[0]}",
                  ),
                  trailing: Icon(
                    Icons.calendar_month,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onTap: () => _pickDate(isStart: true),
                ),
                Divider(),
                ListTile(
                  title: Text(
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(fontSize: 25),
                    endDate == null
                        ? "Select end date (optional)"
                        : "End:    ${endDate!.toLocal().toString().split(' ')[0]}",
                  ),
                  trailing: Icon(
                    Icons.calendar_month,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onTap: () => _pickDate(isStart: false),
                ),
                Divider(),
                const HeightSpace(16),
                CustomFieldWithTitle(
                  title: "Repeat every (days):",
                  controller: repeatController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final number = int.tryParse(value ?? '');
                    if (number == null || number < 1) {
                      return 'Enter a valid number (min. 1)';
                    }
                    return null;
                  },
                ),
                const HeightSpace(10),
                Divider(),
                const HeightSpace(10),
                PrimaryButtonWidget(onPressed: _submit, buttonText: "Save"),
                const HeightSpace(10),
                PrimaryOutlinedButtonWidget(
                  onPressed: _delete,
                  buttonText: "Delete",
                  textColor: Colors.red,
                  borderColor: Colors.red,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
