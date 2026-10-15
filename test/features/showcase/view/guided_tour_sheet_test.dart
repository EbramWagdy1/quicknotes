import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quicknotes/core/localization/generated/app_localizations.dart';
import 'package:quicknotes/features/showcase/view/guided_tour_sheet.dart';

void main() {
  testWidgets('GuidedTourSheet renders step 1 and advances with Next button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GuidedTourSheet(),
        ),
      ),
    );

    // Initial step: Search & AI
    expect(find.text('Search & AI Semantic Matching'), findsOneWidget);
    expect(find.text('Step 1 of 6'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    // Tap Next
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Step 2: Note Editor
    expect(find.text('Note Editor: Voice, OCR & Checklists'), findsOneWidget);
    expect(find.text('Step 2 of 6'), findsOneWidget);
    expect(find.text('Previous'), findsOneWidget);

    // Tap Previous
    await tester.tap(find.text('Previous'));
    await tester.pumpAndSettle();

    expect(find.text('Search & AI Semantic Matching'), findsOneWidget);
  });

  testWidgets('GuidedTourSheet renders Arabic content in Arabic locale', (
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
        home: Scaffold(
          body: GuidedTourSheet(),
        ),
      ),
    );

    expect(find.text('البحث والبحث الدلالي بالذكاء الاصطناعي'), findsOneWidget);
    expect(find.text('خطوة 1 من 6'), findsOneWidget);
    expect(find.text('التالي'), findsOneWidget);
  });
}
