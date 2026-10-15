import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quicknotes/core/theme/theme_cubit.dart';
import 'package:quicknotes/features/home/view/widgets/home_app_bar.dart';
import 'package:quicknotes/features/home/view_model/cubit/notes_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../view_model/cubit/notes_cubit_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HomeAppBar Theme Toggle Tests', () {
    late FakeNoteDao fakeDao;
    late NotesCubit notesCubit;
    late ThemeCubit themeCubit;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      fakeDao = FakeNoteDao();
      notesCubit = NotesCubit(noteDao: fakeDao);
      themeCubit = ThemeCubit();
    });

    tearDown(() {
      notesCubit.close();
      themeCubit.close();
    });

    testWidgets('renders theme toggle button and toggles between light and dark modes', (tester) async {
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<NotesCubit>.value(value: notesCubit),
            BlocProvider<ThemeCubit>.value(value: themeCubit),
          ],
          child: const MaterialApp(
            home: Scaffold(
              appBar: HomeAppBar(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find theme toggle button by looking for dark_mode_outlined or light_mode_rounded
      final themeToggleFinder = find.byWidgetPredicate(
        (widget) =>
            widget is IconButton &&
            (widget.tooltip == 'Switch to dark mode' || widget.tooltip == 'Switch to light mode'),
      );

      expect(themeToggleFinder, findsOneWidget);

      // Verify initial mode in themeCubit
      expect(themeCubit.state, equals(ThemeMode.system));

      // Tap theme toggle button
      await tester.tap(themeToggleFinder);
      await tester.pumpAndSettle();

      // Should have toggled to dark
      expect(themeCubit.state, equals(ThemeMode.dark));

      // Tap again
      await tester.tap(themeToggleFinder);
      await tester.pumpAndSettle();

      // Should have toggled to light
      expect(themeCubit.state, equals(ThemeMode.light));
    });
  });
}
