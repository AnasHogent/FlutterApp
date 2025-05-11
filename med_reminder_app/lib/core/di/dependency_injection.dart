import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:med_reminder_app/models/medication_reminder.dart';

class SyncService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> trySyncOne(MedicationReminder reminder) async {
    if (!await _hasInternet()) return;
    if (reminder.isSynced) return;

    try {
      await _firestore
          .collection('reminders')
          .doc(reminder.id)
          .set(reminder.toJson());

      reminder.isSynced = true;
      await reminder.save();
    } catch (_) {
      // Je kunt eventueel logging doen hier
    }
  }

  Future<void> syncAllPending() async {
    if (!await _hasInternet()) return;

    final box = Hive.box<MedicationReminder>('medications');
    final unsynced = box.values.where((r) => !r.isSynced).toList();

    for (final reminder in unsynced) {
      await trySyncOne(reminder);
    }
  }

  Future<bool> _hasInternet() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'times': times,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'repeatDays': repeatDays,
    };
  }
}
