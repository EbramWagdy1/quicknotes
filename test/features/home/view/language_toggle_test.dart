import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quicknotes/core/localization/generated/app_localizations.dart';
import 'package:quicknotes/core/localization/locale_cubit.dart';
import 'package:quicknotes/core/theme/theme_cubit.dart';
import 'package:quicknotes/features/home/view/widgets/home_app_bar.dart';
import 'package:quicknotes/features/home/view_model/cubit/notes_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../view_model/cubit/notes_cubit_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HomeAppBar Language Toggle Tests', () {
    late FakeNoteDao fakeDao;
    late NotesCubit notesCubit;
    late ThemeCubit themeCubit;
    late LocaleCubit localeCubit;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      fakeDao = FakeNoteDao();
      notesCubit = NotesCubit(noteDao: fakeDao);
      themeCubit = ThemeCubit();
      localeCubit = LocaleCubit();
    });

    tearDown(() {
      notesCubit.close();
      themeCubit.close();
      localeCubit.close();
    });

    testWidgets('renders language toggle button and toggles between English and Arabic',
        (tester) async {
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<NotesCubit>.value(value: notesCubit),
            BlocProvider<ThemeCubit>.value(value: themeCubit),
            BlocProvider<LocaleCubit>.value(value: localeCubit),
          ],
          child: BlocBuilder<LocaleCubit, Locale>(
            builder: (context, locale) {
              return MaterialApp(
                locale: locale,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: const Scaffold(
                  appBar: HomeAppBar(),
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // In English mode, the app bar title is 'My Notes', and language toggle shows 'عربي'
      expect(find.text('My Notes'), findsOneWidget);
      expect(find.text('عربي'), findsOneWidget);
      expect(localeCubit.isArabic, isFalse);

      // Tap the language toggle button to switch to Arabic
      final langButtonFinder = find.text('عربي');
      await tester.tap(langButtonFinder);
      await tester.pumpAndSettle();

      // Should now be in Arabic mode: title is 'ملاحظاتي', language toggle shows 'EN'
      expect(localeCubit.isArabic, isTrue);
      expect(find.text('ملاحظاتي'), findsOneWidget);
      expect(find.text('EN'), findsOneWidget);

      // Tap the language toggle button to switch back to English
      final enButtonFinder = find.text('EN');
      await tester.tap(enButtonFinder);
      await tester.pumpAndSettle();

      // Should now be in English mode again
      expect(localeCubit.isArabic, isFalse);
      expect(find.text('My Notes'), findsOneWidget);
      expect(find.text('عربي'), findsOneWidget);
    });
  });
}
