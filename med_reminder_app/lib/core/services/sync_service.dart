import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:med_reminder_app/models/medication_reminder.dart';

class SyncService {
  final FirebaseFirestore firestore;

  SyncService(this.firestore);

  Future<void> trySyncOne(MedicationReminder reminder) async {
    if (!await _hasInternet()) return;
    if (reminder.isSynced) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      await firestore
          .collection('users')
          .doc(uid)
          .collection('reminders')
          .doc(reminder.id)
          .set(reminder.toJson());

      reminder.isSynced = true;
      await reminder.save();
    } catch (e) {
      debugPrint('Sync mislukt voor ${reminder.id}: $e');
    }
  }

  Future<void> syncAllPending() async {
    if (!await _hasInternet()) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final box = Hive.box<MedicationReminder>('medications');
    final unsynced = box.values.where((r) => !r.isSynced).toList();

    for (final reminder in unsynced) {
      try {
        await trySyncOne(reminder);
      } catch (e) {
        debugPrint('Sync fout bij ${reminder.id}: $e');
      }
    }
  }

  Future<void> deleteReminder(String id) async {
    if (!await _hasInternet()) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      await firestore
          .collection('users')
          .doc(uid)
          .collection('reminders')
          .doc(id)
          .delete();
      debugPrint("Reminder $id verwijderd uit Firestore");
    } catch (e) {
      debugPrint("Fout bij verwijderen reminder $id: $e");
    }
  }

  Future<bool> _hasInternet() async {
    final List<ConnectivityResult> result =
        await Connectivity().checkConnectivity();
    return result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.bluetooth) ||
        result.contains(ConnectivityResult.ethernet);
  }
}
