import 'package:get_it/get_it.dart';
import 'package:quicknotes/core/database/app_database.dart';
import 'package:quicknotes/core/database/migrations/migration_1_to_2.dart';
import 'package:quicknotes/core/database/migrations/migration_2_to_3.dart';
import 'package:quicknotes/core/database/migrations/migration_3_to_4.dart';
import 'package:quicknotes/core/database/migrations/migration_4_to_5.dart';
import 'package:quicknotes/core/services/alarm_permission_service.dart';
import 'package:quicknotes/core/services/audio_record_service.dart';
import 'package:quicknotes/core/services/biometric_service.dart';
import 'package:quicknotes/core/services/gemini_service.dart';
import 'package:quicknotes/core/services/notification_service.dart';
import 'package:quicknotes/core/services/shake_service.dart';
import 'package:quicknotes/core/services/speech_service.dart';
import 'package:quicknotes/core/localization/locale_cubit.dart';
import 'package:quicknotes/core/routing/app_router.dart';
import 'package:quicknotes/core/routing/app_routes.dart';
import 'package:quicknotes/core/theme/theme_cubit.dart';
import 'package:quicknotes/features/home/view_model/cubit/notes_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> setupDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  final database = await $FloorAppDatabase
      .databaseBuilder('notes.db')
      .addMigrations([migration1to2, migration2to3, migration3to4, migration4to5])
      .build();

  sl.registerSingleton<AppDatabase>(database);
  sl.registerLazySingleton<ShakeService>(() => ShakeService());
  sl.registerLazySingleton<BiometricService>(() => BiometricService());
  sl.registerLazySingleton<GeminiService>(() => GeminiService());
  sl.registerLazySingleton<SpeechService>(() => SpeechService());
  sl.registerLazySingleton<AudioRecordService>(() => AudioRecordService());
  sl.registerLazySingleton<NotificationService>(() => NotificationService());
  sl.registerLazySingleton<AlarmPermissionService>(
    () => AlarmPermissionService(prefs: sl<SharedPreferences>()),
  );

  sl.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(prefs: sl<SharedPreferences>()),
  );

  sl.registerLazySingleton<LocaleCubit>(
    () => LocaleCubit(prefs: sl<SharedPreferences>()),
  );

  sl.registerLazySingleton<NotesCubit>(
    () => NotesCubit(
      noteDao: sl<AppDatabase>().noteDao,
      notificationService: sl<NotificationService>(),
    ),
  );

  // Initialize notifications, request permissions and wire alarm handlers
  final notificationService = sl<NotificationService>();
  await notificationService.initialize();
  notificationService.requestPermissions();

  notificationService.onAlarmTriggered = (noteId) {
    appRouter.push(AppRoutes.alarm, extra: noteId);
  };

  notificationService.onAlarmAction = (noteId, actionId) async {
    if (actionId == 'snooze') {
      if (sl.isRegistered<NotesCubit>()) {
        await sl<NotesCubit>().snoozeNoteById(
          noteId,
          duration: const Duration(minutes: 10),
        );
      }
    } else if (actionId == 'dismiss') {
      if (sl.isRegistered<NotesCubit>()) {
        await sl<NotesCubit>().dismissReminderById(noteId);
      }
    } else {
      // 'in_progress' or tapped notification body
      appRouter.push(AppRoutes.alarm, extra: noteId);
    }
  };
}
