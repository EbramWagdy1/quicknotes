import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quicknotes/features/home/model/note_model.dart';
import 'package:quicknotes/features/home/model/subtask_model.dart';
import 'package:quicknotes/features/home/view/widgets/note_card.dart';
import 'package:quicknotes/features/home/view_model/cubit/notes_cubit.dart';

import '../view_model/cubit/notes_cubit_test.dart';

void main() {
  group('NoteCard Subtasks Direct Interaction Tests', () {
    late FakeNoteDao fakeDao;
    late NotesCubit cubit;

    setUp(() {
      fakeDao = FakeNoteDao();
      cubit = NotesCubit(noteDao: fakeDao);
    });

    tearDown(() {
      cubit.close();
    });

    testWidgets(
      'renders subtasks directly on card and tapping checkbox toggles task without opening card',
      (tester) async {
        final now = DateTime.now();
        final note = Note(
          id: 1,
          title: 'Trip Checklist',
          body: '',
          createdAt: now,
          updatedAt: now,
          subtasks: const [
            Subtask(id: 's1', title: 'Pack passport', isCompleted: false),
            Subtask(id: 's2', title: 'Buy tickets', isCompleted: true),
          ],
        );

        // Preload note in cubit
        await fakeDao.insertNote(
          (await cubit.noteDao.getAllNotes()).isEmpty
              ? (await () async {
                  await cubit.addNote(
                    title: note.title,
                    body: note.body,
                    subtasks: note.subtasks,
                  );
                  return (await fakeDao.getAllNotes()).first;
                }())
              : (await fakeDao.getAllNotes()).first,
        );

        bool cardTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: cubit,
                child: NoteCard(
                  note: note,
                  onTap: () {
                    cardTapped = true;
                  },
                ),
              ),
            ),
          ),
        );

        // Verify subtasks are visible on the card
        expect(find.text('Pack passport'), findsOneWidget);
        expect(find.text('Buy tickets'), findsOneWidget);

        final checkboxFinder = find.descendant(
          of: find.byType(NoteCard),
          matching: find.byType(AnimatedContainer),
        );

        expect(checkboxFinder, findsWidgets);

        // Tap the first checkbox
        await tester.tap(checkboxFinder.first);
        await tester.pumpAndSettle();

        // Card tap should NOT be triggered
        expect(cardTapped, false);

        // Cubit should have updated the note subtask to completed
        final loaded = cubit.state as NotesLoaded;
        expect(loaded.notes.first.subtasks.first.isCompleted, true);
      },
    );

    testWidgets('renders reminder chip when note has reminderAt', (tester) async {
      final now = DateTime.now();
      final futureReminder = now.add(const Duration(hours: 3));
      final noteWithReminder = Note(
        id: 2,
        title: 'Meeting with Client',
        body: 'Prepare slide deck',
        createdAt: now,
        updatedAt: now,
        reminderAt: futureReminder,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: cubit,
              child: NoteCard(
                note: noteWithReminder,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.alarm_rounded), findsOneWidget);
    });

    testWidgets('renders overdue reminder chip with alarm_off icon when reminder is in the past', (tester) async {
      final now = DateTime.now();
      final pastReminder = now.subtract(const Duration(hours: 1));
      final noteWithPastReminder = Note(
        id: 3,
        title: 'Overdue Task',
        body: 'Urgent submission',
        createdAt: now,
        updatedAt: now,
        reminderAt: pastReminder,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: cubit,
              child: NoteCard(
                note: noteWithPastReminder,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.alarm_off_rounded), findsOneWidget);
    });
  });
}
