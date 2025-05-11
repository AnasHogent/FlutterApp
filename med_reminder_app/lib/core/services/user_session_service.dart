import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:med_reminder_app/core/constants/data_saved.dart';
import 'package:med_reminder_app/screens/auth/models/user_model.dart';

class UserSessionService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> restoreSession() async {
    final user = _auth.currentUser;

    if (user == null) {
      UserData.userModel = null;
      return;
    }

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      UserData.userModel = UserModel.fromJson(doc.data()!);
    } else {
      UserData.userModel = null;
    }
  }

  bool isLoggedIn() => _auth.currentUser != null;
}
