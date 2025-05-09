import 'package:flutter/material.dart';
import 'package:med_reminder_app/core/styling/app_colors.dart';
import 'package:med_reminder_app/core/styling/app_styles.dart';
import 'package:med_reminder_app/core/widgets/custom_field_with_title.dart';
import 'package:med_reminder_app/core/widgets/custom_text_field.dart';
import 'package:med_reminder_app/core/widgets/primary_Outlined_button_widget.dart';
import 'package:med_reminder_app/core/widgets/primary_button_widget.dart';
import 'package:med_reminder_app/core/widgets/spacing_widgates.dart';
import 'package:med_reminder_app/models/medication_reminder.dart';

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
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: AppColors.whiteColor,
              onSurface: AppColors.blackColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryColor, // CANCEL/OK color
              ),
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
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: AppColors.whiteColor,
              onSurface: AppColors.blackColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
              ),
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
            content: Text('Please select at least one time and a start date.'),
          ),
        );
        return;
      }
    }
    final updatedReminder =
        widget.reminder
          ..name = medicationNameController.text.trim()
          ..times = times.map((t) => t.format(context)).toList()
          ..startDate = startDate!
          ..endDate = endDate
          ..repeatDays = repeatEveryXDays
          ..isSynced = false;

    // Hive propleem
    await updatedReminder.save();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Medication updated')));

    Navigator.of(context).pop();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final reminder = widget.reminder;
    medicationNameController.text = reminder.name;
    repeatController.text = reminder.repeatDays.toString();
    times.addAll(
      reminder.times.map((t) {
        final parts = t.split(":");
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }),
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
          padding: const EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: ListView(
              children: [
                const HeightSpace(10),
                Text("Medication name:", style: AppStyles.black16w500Style),
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
                PrimaryOutlinedButtonWidget(
                  onPressed: _pickTime,
                  buttonText: "Add time(s)",
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
                    style: AppStyles.black16w500Style.copyWith(fontSize: 25),
                    startDate == null
                        ? "Select start date"
                        : "Start: ${startDate!.toLocal().toString().split(' ')[0]}",
                  ),
                  trailing: const Icon(Icons.calendar_month),
                  onTap: () => _pickDate(isStart: true),
                ),
                Divider(),
                ListTile(
                  title: Text(
                    style: AppStyles.black16w500Style.copyWith(fontSize: 25),
                    endDate == null
                        ? "Select end date (optional)"
                        : "End: ${endDate!.toLocal().toString().split(' ')[0]}",
                  ),
                  trailing: const Icon(Icons.calendar_month),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
