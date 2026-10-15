import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quicknotes/core/database/entities/note_entity.dart';
import 'package:quicknotes/features/calendar/view/calendar_view.dart';
import 'package:quicknotes/features/calendar/view/widgets/calendar_grid.dart';
import 'package:quicknotes/features/calendar/view/widgets/calendar_header.dart';
import 'package:quicknotes/features/home/view_model/cubit/notes_cubit.dart';

import '../../home/view_model/cubit/notes_cubit_test.dart';

void main() {
  group('CalendarView Widget Tests', () {
    late FakeNoteDao fakeDao;
    late NotesCubit cubit;

    setUp(() {
      fakeDao = FakeNoteDao();
      cubit = NotesCubit(noteDao: fakeDao);
    });

    tearDown(() {
      cubit.close();
    });

    testWidgets('renders CalendarView with title, header, grid and today chip', (tester) async {
      await cubit.loadNotes();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<NotesCubit>.value(
            value: cubit,
            child: const CalendarView(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Notes Calendar'), findsOneWidget);
      expect(find.byType(CalendarHeader), findsOneWidget);
      expect(find.byType(CalendarGrid), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Reminders Only'), findsOneWidget);
      expect(find.text('Mo'), findsOneWidget);
      expect(find.text('Tu'), findsOneWidget);
      expect(find.text('Su'), findsOneWidget);
    });

    testWidgets('allows navigating between months via previous and next buttons', (tester) async {
      await cubit.loadNotes();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<NotesCubit>.value(
            value: cubit,
            child: const CalendarView(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final currentMonthText = find.byTooltip('Next month');
      expect(currentMonthText, findsOneWidget);

      // Tap next month
      await tester.tap(find.byTooltip('Next month'));
      await tester.pumpAndSettle();

      // Tap today chip to return
      await tester.tap(find.text('Today'));
      await tester.pumpAndSettle();

      // Tap previous month
      await tester.tap(find.byTooltip('Previous month'));
      await tester.pumpAndSettle();
    });

    testWidgets('displays notes for selected day and empty state for day without notes', (tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 10, 0);

      await fakeDao.insertNote(
        NoteEntity(
          id: 1,
          title: 'Planning Session',
          body: 'Discuss next milestones',
          createdAt: today,
          updatedAt: today,
          reminderAt: today.add(const Duration(hours: 1)),
        ),
      );

      await cubit.loadNotes();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<NotesCubit>.value(
            value: cubit,
            child: const CalendarView(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Today's note should be rendered
      expect(find.text('Planning Session'), findsOneWidget);
      expect(find.text('1 note'), findsOneWidget);

      // Select previous month
      await tester.tap(find.byTooltip('Previous month'));
      await tester.pumpAndSettle();

      // In empty month, empty state is displayed
      expect(find.text('No notes for this date'), findsOneWidget);
    });

    testWidgets('toggling reminders only chip filters notes correctly', (tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 10, 0);

      // Note 1 without reminder
      await fakeDao.insertNote(
        NoteEntity(
          id: 1,
          title: 'Regular Note',
          body: 'No reminder here',
          createdAt: today,
          updatedAt: today,
        ),
      );

      // Note 2 with reminder today
      await fakeDao.insertNote(
        NoteEntity(
          id: 2,
          title: 'Doctor Appointment',
          body: 'Bring test results',
          createdAt: today,
          updatedAt: today,
          reminderAt: today.add(const Duration(hours: 1)),
        ),
      );

      await cubit.loadNotes();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<NotesCubit>.value(
            value: cubit,
            child: const CalendarView(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Both notes visible initially
      expect(find.text('Regular Note'), findsOneWidget);
      expect(find.text('Doctor Appointment'), findsOneWidget);
      expect(find.text('2 notes'), findsOneWidget);

      // Tap "Reminders Only" filter chip
      await tester.tap(find.text('Reminders Only'));
      await tester.pumpAndSettle();

      // Only note with reminder should remain visible
      expect(find.text('Regular Note'), findsNothing);
      expect(find.text('Doctor Appointment'), findsOneWidget);
      expect(find.text('1 note'), findsOneWidget);
    });
  });
}
