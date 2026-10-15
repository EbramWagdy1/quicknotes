import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quicknotes/core/localization/generated/app_localizations.dart';
import 'package:quicknotes/core/theme/app_theme.dart';
import 'package:quicknotes/core/utils/app_strings.dart';
import 'package:quicknotes/features/splash/view/splash_view.dart';

void main() {
  testWidgets('SplashScreen renders animated logo and title transitions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

    final column = find.byType(Column);
    expect(
      find.descendant(of: column, matching: find.byType(ScaleTransition)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: column, matching: find.byType(SlideTransition)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: column, matching: find.byType(FadeTransition)),
      findsNWidgets(2),
    );
    expect(find.text(AppStrings.appName), findsOneWidget);

    // Advance animation partially
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.text(AppStrings.appName), findsOneWidget);

    // Advance animation to completion before timer
    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.text(AppStrings.appName), findsOneWidget);
  });

  testWidgets('SplashScreen renders title with darkTextPrimary in dark mode', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const SplashScreen(),
      ),
    );

    final textFinder = find.text(AppStrings.appName);
    expect(textFinder, findsOneWidget);

    final Text textWidget = tester.widget(textFinder);
    expect(textWidget.style?.color, equals(AppTheme.darkTextPrimary));
  });

  testWidgets('SplashScreen renders Arabic app title in Arabic locale', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('ar'),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: SplashScreen(),
      ),
    );

    expect(find.text('الملاحظات السريعة'), findsOneWidget);
  });
}

