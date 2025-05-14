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
    if (!await hasInternet()) return;
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
    if (!await hasInternet()) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final box = Hive.box<MedicationReminder>('medications');
    final localReminders = box.values.toList();

    for (final reminder in localReminders) {
      try {
        final docRef = firestore
            .collection('users')
            .doc(uid)
            .collection('reminders')
            .doc(reminder.id);

        if (reminder.isDeleted) {
          await docRef.delete();
          await reminder.delete();
        } else if (!reminder.isSynced) {
          await docRef.set(reminder.toJson());
          reminder.isSynced = true;
          await reminder.save();
        }
      } catch (e) {
        debugPrint("Sync fout bij ${reminder.id}: $e");
      }
    }

    try {
      final snapshot =
          await firestore
              .collection('users')
              .doc(uid)
              .collection('reminders')
              .get();

      for (final doc in snapshot.docs) {
        if (!box.containsKey(doc.id)) {
          final newReminder = MedicationReminder.fromJson(doc.data());
          await box.put(newReminder.id, newReminder);
          debugPrint("Reminder toegevoegd vanuit Firestore: ${newReminder.id}");
        }
      }
    } catch (e) {
      debugPrint("Fout bij ophalen Firestore reminders: $e");
    }
  }

  Future<void> deleteReminder(MedicationReminder reminder) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final box = Hive.box<MedicationReminder>('medications');

    reminder.isDeleted = true;
    reminder.isSynced = false;
    await reminder.save();

    if (!await hasInternet()) return;

    try {
      await firestore
          .collection('users')
          .doc(uid)
          .collection('reminders')
          .doc(reminder.id)
          .delete();

      await box.delete(reminder.id);
      debugPrint(
        "Reminder ${reminder.id} permanent verwijderd (Firestore & Hive)",
      );
    } catch (e) {
      debugPrint("Fout bij verwijderen reminder ${reminder.id}: $e");
    }
  }

  Future<bool> hasInternet() async {
    final List<ConnectivityResult> result =
        await Connectivity().checkConnectivity();
    return result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.bluetooth) ||
        result.contains(ConnectivityResult.ethernet);
  }
}
