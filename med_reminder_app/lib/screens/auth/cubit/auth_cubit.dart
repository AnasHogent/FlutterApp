import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:med_reminder_app/core/constants/data_saved.dart';
import 'package:med_reminder_app/core/services/notification_service.dart';
import 'package:med_reminder_app/models/medication_reminder.dart';
import 'package:med_reminder_app/screens/add/add_medication_screen.dart';
import 'package:med_reminder_app/screens/auth/cubit/auth_state.dart';
import 'package:med_reminder_app/screens/auth/repo/auth_repo.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._authRepo) : super(AuthInitial());

  final AuthRepo _authRepo;

  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());

    final result = await _authRepo.loginUser(email: email, password: password);

    result.fold(
      (error) {
        emit(AuthError(error));
      },
      (userModel) {
        UserData.userModel = userModel;

        Hive.box<MedicationReminder>('medications').clear();
        final notificationService = sl<NotificationService>();
        notificationService.cancelAllNotifications();

        emit(AuthSuccess("Login In Successfully"));
      },
    );
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());

    final result = await _authRepo.registerUser(
      username: username,
      email: email,
      password: password,
    );

    result.fold((error) => emit(AuthError(error)), (userModel) {
      UserData.userModel = userModel;
      emit(AuthSuccess("Registered Successfully"));
    });
  }

  Future<void> logout() async {
    emit(AuthLoading());

    final result = await _authRepo.logoutUser();

    result.fold((error) => emit(AuthError(error)), (success) {
      UserData.userModel = null;
      emit(AuthLoggedOut(success));
    });
  }

  Future<void> loginWithGoogle() async {
    if (state is AuthLoading) return;
    emit(AuthLoading());
    final result = await _authRepo.loginWithGoogle();
    result.fold((error) => emit(AuthError(error)), (userModel) {
      UserData.userModel = userModel;
      emit(AuthSuccess("Google Login Successful"));
    });
  }
}
