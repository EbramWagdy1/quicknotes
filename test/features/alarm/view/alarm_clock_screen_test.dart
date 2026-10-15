import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quicknotes/core/localization/generated/app_localizations.dart';
import 'package:quicknotes/core/services/notification_service.dart';
import 'package:quicknotes/features/alarm/view/alarm_clock_screen.dart';
import 'package:quicknotes/features/home/model/note_model.dart';
import 'package:quicknotes/features/home/view_model/cubit/notes_cubit.dart';

import '../../../features/home/view_model/cubit/notes_cubit_test.dart';

void main() {
  late FakeNoteDao fakeDao;
  late NotificationService fakeNotificationService;
  late NotesCubit notesCubit;

  setUp(() {
    fakeDao = FakeNoteDao();
    fakeNotificationService = NotificationService();
    notesCubit = NotesCubit(
      noteDao: fakeDao,
      notificationService: fakeNotificationService,
    );
  });

  tearDown(() {
    notesCubit.close();
  });

  Widget createTestWidget({required Note note}) {
    return BlocProvider<NotesCubit>.value(
      value: notesCubit,
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('ar'),
        ],
        locale: const Locale('ar'),
        home: AlarmClockScreen(note: note),
      ),
    );
  }

  testWidgets('AlarmClockScreen renders time, note title, in-progress, snooze, and dismiss buttons',
      (tester) async {
    final note = Note(
      id: 99,
      title: 'مهمة هامة جداً',
      body: 'تفاصيل الملاحظة للمنبه',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      reminderAt: DateTime.now().add(const Duration(minutes: 5)),
    );

    await tester.pumpWidget(createTestWidget(note: note));
    await tester.pump();

    // Verify Note title is rendered
    expect(find.text('مهمة هامة جداً'), findsOneWidget);
    expect(find.text('تفاصيل الملاحظة للمنبه'), findsOneWidget);

    // Verify Action buttons are rendered
    expect(find.text('جاري العمل'), findsOneWidget);
    expect(find.text('أجّل'), findsOneWidget);
    expect(find.text('إيقاف'), findsOneWidget);

    // Tap "أجّل" to open snooze bottom sheet
    await tester.tap(find.text('أجّل'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify bottom sheet options appear
    expect(find.text('5 دقائق'), findsOneWidget);
    expect(find.text('10 دقائق (الموصى به)'), findsOneWidget);
  });
}
