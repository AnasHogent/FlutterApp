import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:med_reminder_app/core/constants/data_saved.dart';
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
}
