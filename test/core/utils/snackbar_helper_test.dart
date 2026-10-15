import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quicknotes/core/utils/snackbar_helper.dart';
import 'package:quicknotes/features/home/model/note_model.dart';
import 'package:quicknotes/features/home/view_model/cubit/notes_cubit.dart';
import '../../features/home/view_model/cubit/notes_cubit_test.dart';

void main() {
  testWidgets('showDeleteUndoSnackBar auto-dismisses after 10 seconds even with accessibleNavigation', (
    WidgetTester tester,
  ) async {
    final fakeDao = FakeNoteDao();
    final cubit = NotesCubit(noteDao: fakeDao);

    await tester.pumpWidget(
      MaterialApp(
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        home: MediaQuery(
          data: const MediaQueryData(accessibleNavigation: true),
          child: const Scaffold(
            body: Text('Test Body'),
          ),
        ),
      ),
    );

    final note = Note(
      id: 1,
      title: 'ddd',
      body: 'test body',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    SnackbarHelper.showDeleteUndoSnackBar(note: note, cubit: cubit);
    await tester.pumpAndSettle();

    expect(find.text('Note "ddd" deleted'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);

    // Fast-forward 10 seconds
    await tester.pump(const Duration(seconds: 10));
    await tester.pumpAndSettle();

    expect(find.text('Note "ddd" deleted'), findsNothing);
    await cubit.close();
  });

  testWidgets('tapping Undo dismisses snackbar immediately and restores note', (
    WidgetTester tester,
  ) async {
    final fakeDao = FakeNoteDao();
    final cubit = NotesCubit(noteDao: fakeDao);

    await tester.pumpWidget(
      MaterialApp(
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        home: const Scaffold(
          body: Text('Test Body'),
        ),
      ),
    );

    final note = Note(
      id: 1,
      title: 'ddd',
      body: 'test body',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    SnackbarHelper.showDeleteUndoSnackBar(note: note, cubit: cubit);
    await tester.pumpAndSettle();

    expect(find.text('Undo'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(find.text('Note "ddd" deleted'), findsNothing);
    await cubit.close();
  });
}
