import 'package:get_it/get_it.dart';
import 'package:med_reminder_app/screens/auth/cubit/auth_cubit.dart';
import 'package:med_reminder_app/screens/auth/repo/auth_repo.dart';

GetIt sl = GetIt.instance;

Future<void> initDI() async {
  sl.registerSingleton<AuthRepo>(AuthRepo());

  sl.registerFactory(() => AuthCubit(sl<AuthRepo>()));
}
