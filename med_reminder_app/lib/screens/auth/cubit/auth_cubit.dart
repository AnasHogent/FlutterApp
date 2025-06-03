import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:med_reminder_app/core/constants/data_saved.dart';
import 'package:med_reminder_app/core/di/dependency_injection.dart';
import 'package:med_reminder_app/core/services/user_session_service.dart';
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
      (userModel) async {
        UserData.userModel = userModel;
        await sl<UserSessionService>().setupUserSession();
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

    result.fold((error) => emit(AuthError(error)), (success) async {
      await sl<UserSessionService>().clearUserSession();
      UserData.userModel = null;
      emit(AuthLoggedOut(success));
    });
  }

  Future<void> loginWithGoogle() async {
    if (state is AuthLoading) return;
    emit(AuthLoading());
    final result = await _authRepo.loginWithGoogle();
    result.fold((error) => emit(AuthError(error)), (userModel) async {
      UserData.userModel = userModel;
      await sl<UserSessionService>().setupUserSession();
      emit(AuthSuccess("Google Login Successful"));
    });
  }
}
