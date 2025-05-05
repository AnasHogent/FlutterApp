import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:med_reminder_app/screens/auth/models/user_model.dart';

class AuthRepo {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<Either<String, String>> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final existing =
          await firestore
              .collection('users')
              .where('username', isEqualTo: username)
              .limit(1)
              .get();

      if (existing.docs.isNotEmpty) {
        return const Left('Username is already taken');
      }
      final emailExists =
          await firestore
              .collection('users')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (emailExists.docs.isNotEmpty) {
        return const Left('This email is already used');
      }
      UserCredential user = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await firestore.collection("users").doc(user.user!.uid).set({
        "username": username,
        "email": email,
        "uid": user.user!.uid,
      });

      return const Right("✔️ Account created successfully");
    } on FirebaseAuthException catch (e) {
      return Left(e.message ?? "Something went wrong");
    } catch (e) {
      return Left("Unexpected error: $e");
    }
  }

  Future<Either<String, UserModel>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential user = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // بعد تسجيل الدخول، نجيب بيانات المستخدم من Firestore
      final userDoc =
          await firestore.collection('users').doc(user.user!.uid).get();

      if (!userDoc.exists) {
        return const Left("❌ No user data found");
      }

      final userModel = UserModel.fromJson(userDoc.data()!);

      return Right(userModel);
    } on FirebaseAuthException catch (e) {
      String errorMsg;

      switch (e.code) {
        case 'user-not-found':
          errorMsg = 'No user found with this email';
          break;
        case 'wrong-password':
          errorMsg = 'Incorrect password';
          break;
        case 'invalid-email':
          errorMsg = 'Email format is invalid';
          break;
        default:
          errorMsg = e.message ?? 'Login failed';
      }
      return Left("❌ $errorMsg");
    } catch (e) {
      return Left("Unexpected error: $e");
    }
  }

  Future<Either<String, String>> logoutUser() async {
    try {
      await firebaseAuth.signOut();
      return const Right("🚪 Logged out successfully");
    } catch (e) {
      return Left("❌ Logout failed: $e");
    }
  }
}
