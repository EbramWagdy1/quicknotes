import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quicknotes/core/services/gemini_service.dart';

void main() {
  group('GeminiService Unit Tests', () {
    test('throws GeminiException when body is empty or whitespace', () async {
      final service = GeminiService(apiKey: 'dummy_key');

      expect(
        () => service.summarizeNote(title: 'Empty Note', body: '   '),
        throwsA(isA<GeminiException>().having(
          (e) => e.kind,
          'kind',
          equals(GeminiErrorKind.emptyInput),
        )),
      );
    });

    test('suggestTags returns empty list when title and body are empty', () async {
      final service = GeminiService(apiKey: 'dummy_key');
      final tags = await service.suggestTags(title: '   ', body: '   ');
      expect(tags, isEmpty);
    });

    test('extractTasks returns empty list when body is empty', () async {
      final service = GeminiService(apiKey: 'dummy_key');
      final tasks = await service.extractTasks(title: 'Title', body: '   ');
      expect(tasks, isEmpty);
    });

    test('semanticSearch returns empty list when query or notesSummary is empty', () async {
      final service = GeminiService(apiKey: 'dummy_key');
      final results1 = await service.semanticSearch(query: '  ', notesSummary: [{'id': 1}]);
      expect(results1, isEmpty);

      final results2 = await service.semanticSearch(query: 'find food', notesSummary: []);
      expect(results2, isEmpty);
    });

    test('isConfigured is false and client throws when apiKey is empty', () async {
      final unconfiguredService = GeminiService(apiKey: '');
      expect(unconfiguredService.isConfigured, isFalse);
      expect(
        () => unconfiguredService.summarizeNote(title: 'T', body: 'Valid body text'),
        throwsA(isA<GeminiException>().having(
          (e) => e.kind,
          'kind',
          equals(GeminiErrorKind.apiKeyMissingOrInvalid),
        )),
      );
    });

    test('defaults to openai/gpt-oss-20b and exposes defaultCandidateModels', () {
      final service = GeminiService(apiKey: 'dummy_key');
      expect(service.activeModelName, 'openai/gpt-oss-20b');
      expect(GeminiService.defaultCandidateModels, contains('openai/gpt-oss-20b'));
      expect(GeminiService.defaultCandidateModels, contains('qwen/qwen3.8-27b'));
    });

    test('respects custom candidate models and custom initial model', () {
      final service = GeminiService(
        apiKey: 'dummy_key',
        modelName: 'qwen/qwen3.8-27b',
        candidateModels: ['qwen/qwen3.8-27b', 'openai/gpt-oss-20b'],
      );
      expect(service.activeModelName, 'qwen/qwen3.8-27b');
    });

    test('GeminiException localizedMessage outputs clean messages for Arabic & English', () {
      const exRateLimit = GeminiException(
        'Raw quota 429',
        kind: GeminiErrorKind.rateLimit,
      );
      expect(exRateLimit.localizedMessage(true), contains('تم تجاوز الحد المسموح'));
      expect(exRateLimit.localizedMessage(false), contains('rate limit'));

      const exNetwork = GeminiException(
        'SocketException OS Error',
        kind: GeminiErrorKind.network,
      );
      expect(exNetwork.localizedMessage(true), contains('تعذر الاتصال بالإنترنت'));
      expect(exNetwork.localizedMessage(false), contains('No internet connection'));

      const exUnavailable = GeminiException(
        '404 model not found',
        kind: GeminiErrorKind.serviceUnavailable,
      );
      expect(exUnavailable.localizedMessage(true), contains('قيد التحديث'));
      expect(exUnavailable.localizedMessage(false), contains('temporarily updating'));
    });

    test('getUserFriendlyError sanitizes raw Gemini deprecation/404 messages completely', () {
      const rawApiError =
          'Gemini error: models/gemini-1.5-flash is not found for API version v1beta, or is not supported for generateContent. Call ModelService.ListModels to see the list of available models and their supported methods.';

      final arabicMsg = GeminiService.getUserFriendlyError(rawApiError, isArabic: true);
      final englishMsg = GeminiService.getUserFriendlyError(rawApiError, isArabic: false);

      // Verify no technical jargon is ever leaked to user
      expect(arabicMsg, isNot(contains('v1beta')));
      expect(arabicMsg, isNot(contains('ModelService')));
      expect(arabicMsg, isNot(contains('generateContent')));
      expect(arabicMsg, contains('خدمة الذكاء الاصطناعي قيد التحديث'));

      expect(englishMsg, isNot(contains('v1beta')));
      expect(englishMsg, isNot(contains('ModelService')));
      expect(englishMsg, isNot(contains('generateContent')));
      expect(englishMsg, contains('temporarily updating'));
    });

    test('getUserFriendlyError sanitizes network and quota errors', () {
      const rawSocket = 'SocketException: Failed host lookup: generativelanguage.googleapis.com';
      expect(
        GeminiService.getUserFriendlyError(rawSocket, isArabic: true),
        contains('تعذر الاتصال بالإنترنت'),
      );
      expect(
        GeminiService.getUserFriendlyError(rawSocket, isArabic: false),
        contains('No internet connection'),
      );

      const rawQuota = 'Resource has been exhausted (e.g. check quota, 429)';
      expect(
        GeminiService.getUserFriendlyError(rawQuota, isArabic: true),
        contains('تم تجاوز الحد المسموح'),
      );
      expect(
        GeminiService.getUserFriendlyError(rawQuota, isArabic: false),
        contains('rate limit reached'),
      );
    });

    test('getUserFriendlyError safely falls back for unclassified exceptions', () {
      final genericError = Exception('Some internal parsing glitch in library');
      final arMsg = GeminiService.getUserFriendlyError(genericError, isArabic: true);
      final enMsg = GeminiService.getUserFriendlyError(genericError, isArabic: false);

      expect(arMsg, contains('تعذر إتمام العملية'));
      expect(enMsg, contains('Unable to complete AI operation'));
    });

    group('Monthly AI Quota Limitation & Automatic Rollover', () {
      test('defaults to 50 requests and handles null prefs gracefully', () {
        final service = GeminiService(apiKey: 'dummy_key');
        expect(service.monthlyQuota, equals(50));
        expect(service.getUsedMonthlyQuota(), equals(0));
        expect(service.getRemainingMonthlyQuota(), equals(50));
        // checkMonthlyQuota should not throw when prefs is null
        expect(() => service.checkMonthlyQuota(), returnsNormally);
      });

      test('custom quota is respected', () {
        final service = GeminiService(apiKey: 'dummy_key', monthlyQuota: 20);
        expect(service.monthlyQuota, equals(20));
        expect(service.getRemainingMonthlyQuota(), equals(20));
      });

      test('tracks usage and decrements remaining quota on success', () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final now = DateTime(2026, 10, 15);

        final service = GeminiService(
          apiKey: 'dummy_key',
          prefs: prefs,
          monthlyQuota: 3,
        );

        expect(service.getUsedMonthlyQuota(now: now), equals(0));
        expect(service.getRemainingMonthlyQuota(now: now), equals(3));

        // First successful request
        await service.recordSuccessfulRequest(now: now);
        expect(service.getUsedMonthlyQuota(now: now), equals(1));
        expect(service.getRemainingMonthlyQuota(now: now), equals(2));

        // Second successful request
        await service.recordSuccessfulRequest(now: now);
        expect(service.getUsedMonthlyQuota(now: now), equals(2));
        expect(service.getRemainingMonthlyQuota(now: now), equals(1));

        // Third successful request (consumes all quota)
        await service.recordSuccessfulRequest(now: now);
        expect(service.getUsedMonthlyQuota(now: now), equals(3));
        expect(service.getRemainingMonthlyQuota(now: now), equals(0));
      });

      test('throws GeminiException with monthlyLimitExceeded when quota is reached', () async {
        SharedPreferences.setMockInitialValues({
          GeminiService.keyAiQuotaMonth: '2026-10',
          GeminiService.keyAiQuotaUsed: 5,
        });
        final prefs = await SharedPreferences.getInstance();
        final now = DateTime(2026, 10, 20);

        final service = GeminiService(
          apiKey: 'dummy_key',
          prefs: prefs,
          monthlyQuota: 5,
        );

        expect(
          () => service.checkMonthlyQuota(now: now),
          throwsA(isA<GeminiException>().having(
            (e) => e.kind,
            'kind',
            equals(GeminiErrorKind.monthlyLimitExceeded),
          )),
        );

        // Verify friendly message
        try {
          service.checkMonthlyQuota(now: now);
        } catch (e) {
          expect(e, isA<GeminiException>());
          final geminiEx = e as GeminiException;
          expect(geminiEx.localizedMessage(true), contains('تم استهلاك رصيدك الشهري'));
          expect(geminiEx.localizedMessage(false), contains('monthly AI limit'));
        }
      });

      test('automatically rolls over and resets usage counter on a new month', () async {
        // Oct 2026: User consumed all 5 requests
        SharedPreferences.setMockInitialValues({
          GeminiService.keyAiQuotaMonth: '2026-10',
          GeminiService.keyAiQuotaUsed: 5,
        });
        final prefs = await SharedPreferences.getInstance();

        final service = GeminiService(
          apiKey: 'dummy_key',
          prefs: prefs,
          monthlyQuota: 5,
        );

        final octDate = DateTime(2026, 10, 31);
        expect(service.getUsedMonthlyQuota(now: octDate), equals(5));
        expect(service.getRemainingMonthlyQuota(now: octDate), equals(0));

        // Nov 1st 2026: Month advances!
        final novDate = DateTime(2026, 11, 1);
        expect(service.getUsedMonthlyQuota(now: novDate), equals(0));
        expect(service.getRemainingMonthlyQuota(now: novDate), equals(5));

        // checkMonthlyQuota should not throw, it should reset storage
        expect(() => service.checkMonthlyQuota(now: novDate), returnsNormally);
        expect(prefs.getString(GeminiService.keyAiQuotaMonth), equals('2026-11'));
        expect(prefs.getInt(GeminiService.keyAiQuotaUsed), equals(0));

        // User can make new requests in November
        await service.recordSuccessfulRequest(now: novDate);
        expect(service.getUsedMonthlyQuota(now: novDate), equals(1));
        expect(service.getRemainingMonthlyQuota(now: novDate), equals(4));
      });
    });
  });
}
