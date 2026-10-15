import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:quicknotes/core/services/gemini_service.dart';
import 'package:quicknotes/features/home/view/widgets/ai_summary_sheet.dart';

class MockGeminiService extends Fake implements GeminiService {
  String? nextSummary;
  Exception? errorToThrow;
  int callCount = 0;

  @override
  Future<String> summarizeNote({
    required String title,
    required String body,
  }) async {
    callCount++;
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    return nextSummary ?? 'Default summary result';
  }
}

void main() {
  final sl = GetIt.instance;
  late MockGeminiService mockGemini;

  setUp(() {
    mockGemini = MockGeminiService();
    if (sl.isRegistered<GeminiService>()) {
      sl.unregister<GeminiService>();
    }
    sl.registerSingleton<GeminiService>(mockGemini);
  });

  tearDown(() {
    if (sl.isRegistered<GeminiService>()) {
      sl.unregister<GeminiService>();
    }
  });

  Widget buildTestableWidget({
    required Widget child,
    Locale locale = const Locale('ar'),
  }) {
    return MaterialApp(
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(body: child),
    );
  }

  group('AiSummarySheet Widget Tests', () {
    testWidgets('renders loading state then displays summary successfully', (tester) async {
      mockGemini.nextSummary = 'هذا ملخص تجريبي للملاحظة تم إنشاؤه بالذكاء الاصطناعي';

      await tester.pumpWidget(
        buildTestableWidget(
          child: const AiSummarySheet(
            noteTitle: 'عنوان تجريبي',
            noteContent: 'محتوى طويل جداً للملاحظة يحتاج إلى تلخيص من الذكاء الاصطناعي',
          ),
        ),
      );

      // Initially shows loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      // Displays summary text
      expect(find.text('هذا ملخص تجريبي للملاحظة تم إنشاؤه بالذكاء الاصطناعي'), findsOneWidget);
      // Displays modern footer
      expect(find.text('مدعوم بواسطة Google Gemini AI'), findsOneWidget);
    });

    testWidgets('displays friendly Arabic error when Gemini fails with 404/unavailable and retries',
        (tester) async {
      mockGemini.errorToThrow = const GeminiException(
        'Gemini error: models/gemini-1.5-flash is not found for API version v1beta, or is not supported for generateContent. Call ModelService.ListModels',
        kind: GeminiErrorKind.serviceUnavailable,
      );

      await tester.pumpWidget(
        buildTestableWidget(
          locale: const Locale('ar'),
          child: const AiSummarySheet(
            noteTitle: 'Note',
            noteContent: 'Content to summarize',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify friendly message is shown and raw API jargon is NOT shown
      expect(find.textContaining('v1beta'), findsNothing);
      expect(find.textContaining('ModelService'), findsNothing);
      expect(find.textContaining('خدمة الذكاء الاصطناعي قيد التحديث'), findsOneWidget);

      // Verify retry button exists and works
      final retryButton = find.widgetWithText(OutlinedButton, 'إعادة المحاولة');
      expect(retryButton, findsOneWidget);

      // Simulate recovery on retry
      mockGemini.errorToThrow = null;
      mockGemini.nextSummary = 'تم إنشاء الملخص بعد إعادة المحاولة بنجاح!';

      await tester.tap(retryButton);
      await tester.pump();
      await tester.pumpAndSettle();

      expect(mockGemini.callCount, 2);
      expect(find.text('تم إنشاء الملخص بعد إعادة المحاولة بنجاح!'), findsOneWidget);
    });

    testWidgets('displays friendly English error when locale is English', (tester) async {
      mockGemini.errorToThrow = const GeminiException(
        'Resource has been exhausted (check quota)',
        kind: GeminiErrorKind.rateLimit,
      );

      await tester.pumpWidget(
        buildTestableWidget(
          locale: const Locale('en'),
          child: const AiSummarySheet(
            noteTitle: 'Note',
            noteContent: 'Content to summarize',
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('AI rate limit reached'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Try Again'), findsOneWidget);
    });
  });
}
