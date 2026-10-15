import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:quicknotes/core/di/injection.dart';
import 'package:quicknotes/core/localization/generated/app_localizations.dart';
import 'package:quicknotes/core/services/biometric_service.dart';
import 'package:quicknotes/core/services/shake_service.dart';
import 'package:quicknotes/features/home/model/note_model.dart';
import 'package:quicknotes/features/home/model/subtask_model.dart';
import 'package:quicknotes/features/home/view/note_form_screen.dart';
import 'package:quicknotes/features/home/view/widgets/subtasks_editor.dart';
import 'package:quicknotes/features/home/view_model/cubit/notes_cubit.dart';

import '../view_model/cubit/notes_cubit_test.dart';

class FakeLocalAuthentication extends Fake implements LocalAuthentication {
  @override
  Future<bool> get canCheckBiometrics async => true;

  @override
  Future<bool> isDeviceSupported() async => true;

  @override
  Future<bool> authenticate({
    required String localizedReason,
    dynamic authMessages,
    AuthenticationOptions options = const AuthenticationOptions(),
  }) async => true;
}

void main() {
  group('NoteFormScreen Type Switcher Tests', () {
    late FakeNoteDao fakeDao;
    late NotesCubit cubit;

    setUp(() async {
      await sl.reset();
      fakeDao = FakeNoteDao();
      sl.registerLazySingleton<ShakeService>(() => ShakeService());
      sl.registerLazySingleton<BiometricService>(
        () => BiometricService(auth: FakeLocalAuthentication()),
      );
      cubit = NotesCubit(noteDao: fakeDao);
      sl.registerFactory<NotesCubit>(() => cubit);
    });

    tearDown(() async {
      await cubit.close();
      await sl.reset();
    });

    testWidgets(
        'allows switching between Text Note and Tasks Checklist modes',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: BlocProvider.value(
            value: cubit,
            child: const NoteFormScreen(),
          ),
        ),
      );

      // By default for a new note, "Text Note" is selected
      expect(find.text('Text Note'), findsOneWidget);
      expect(find.text('Tasks Checklist'), findsOneWidget);

      // Body text field is present, SubtasksEditor is not
      expect(find.text('Write your note...'), findsOneWidget);
      expect(find.byType(SubtasksEditor), findsNothing);

      // Tap on Tasks Checklist segmented option
      await tester.tap(find.text('Tasks Checklist'));
      await tester.pumpAndSettle();

      // Now SubtasksEditor is present, Body text field is hidden
      expect(find.byType(SubtasksEditor), findsOneWidget);
      expect(find.text('Write your note...'), findsNothing);

      // Switch back to Text Note
      await tester.tap(find.text('Text Note'));
      await tester.pumpAndSettle();

      expect(find.text('Write your note...'), findsOneWidget);
      expect(find.byType(SubtasksEditor), findsNothing);
    });

    testWidgets(
        'automatically defaults to Checklist mode when opening a note with subtasks',
        (tester) async {
      final now = DateTime.now();
      final checklistNote = Note(
        id: 10,
        title: 'Groceries',
        body: '',
        createdAt: now,
        updatedAt: now,
        subtasks: const [
          Subtask(id: '1', title: 'Milk', isCompleted: false),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: BlocProvider.value(
            value: cubit,
            child: NoteFormScreen(note: checklistNote),
          ),
        ),
      );

      // Should automatically open in Checklist mode
      expect(find.byType(SubtasksEditor), findsOneWidget);
      expect(find.text('Milk'), findsOneWidget);
      expect(find.text('Write your note...'), findsNothing);
    });

    testWidgets('displays reminder status chip and allows clearing reminder in NoteFormScreen', (tester) async {
      final now = DateTime.now();
      final noteWithReminder = Note(
        id: 11,
        title: 'Interview',
        body: 'Online interview at 4 PM',
        createdAt: now,
        updatedAt: now,
        reminderAt: now.add(const Duration(hours: 2)),
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: BlocProvider.value(
            value: cubit,
            child: NoteFormScreen(note: noteWithReminder),
          ),
        ),
      );

      // Verify alarm icon in status chip
      expect(find.byIcon(Icons.alarm_rounded), findsWidgets);

      // Find the clear reminder 'close' button in the chip
      final closeFinder = find.descendant(
        of: find.byType(Container),
        matching: find.byIcon(Icons.close_rounded),
      );
      expect(closeFinder, findsOneWidget);

      // Tap to clear reminder
      await tester.tap(closeFinder);
      await tester.pumpAndSettle();

      // Reminder status chip should be cleared
      expect(closeFinder, findsNothing);
    });
  });
}
