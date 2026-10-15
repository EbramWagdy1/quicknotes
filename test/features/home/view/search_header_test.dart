import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quicknotes/features/home/view/widgets/search_header.dart';
import 'package:quicknotes/features/home/view_model/cubit/notes_cubit.dart';

import '../view_model/cubit/notes_cubit_test.dart';

void main() {
  group('SearchHeader Widget Tests', () {
    late FakeNoteDao fakeDao;
    late NotesCubit cubit;

    setUp(() {
      fakeDao = FakeNoteDao();
      cubit = NotesCubit(noteDao: fakeDao);
    });

    tearDown(() {
      cubit.close();
    });

    testWidgets('typing in SearchHeader updates cubit query', (tester) async {
      await cubit.addNote(title: 'Note 1', body: 'Body 1');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(value: cubit, child: const SearchHeader()),
          ),
        ),
      );

      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'Note 1');
      await tester.pumpAndSettle();

      final state = cubit.state as NotesLoaded;
      expect(state.searchQuery, 'Note 1');
    });

    testWidgets('clear button clears input and resets search query', (
      tester,
    ) async {
      await cubit.addNote(title: 'Note 1', body: 'Body 1');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(value: cubit, child: const SearchHeader()),
          ),
        ),
      );

      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'Query');
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      final state = cubit.state as NotesLoaded;
      expect(state.searchQuery, '');
    });
  });
}
