import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:med_reminder_app/core/services/notification_service.dart';
import 'package:med_reminder_app/core/services/sync_service.dart';
import 'package:med_reminder_app/core/services/user_session_service.dart';
import 'package:med_reminder_app/screens/auth/cubit/auth_cubit.dart';
import 'package:med_reminder_app/screens/auth/repo/auth_repo.dart';

final sl = GetIt.instance;

Future<void> initDI() async {
  // Auth
  sl.registerSingleton<AuthRepo>(AuthRepo());
  sl.registerFactory(() => AuthCubit(sl<AuthRepo>()));
  sl.registerSingleton<UserSessionService>(UserSessionService());

  // firebase
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => SyncService(sl<FirebaseFirestore>()));

  // Notificaties
  final notificationsPlugin = FlutterLocalNotificationsPlugin();
  final notificationService = NotificationService(notificationsPlugin);

  await notificationService.initialize();

  sl.registerSingleton<FlutterLocalNotificationsPlugin>(notificationsPlugin);
  sl.registerSingleton<NotificationService>(notificationService);
}
