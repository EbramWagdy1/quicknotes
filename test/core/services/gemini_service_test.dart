import 'package:flutter_test/flutter_test.dart';
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

    test('defaults to gemini-2.5-flash and exposes defaultCandidateModels', () {
      final service = GeminiService(apiKey: 'dummy_key');
      expect(service.activeModelName, 'gemini-2.5-flash');
      expect(GeminiService.defaultCandidateModels, contains('gemini-2.5-flash'));
      expect(GeminiService.defaultCandidateModels, contains('gemini-flash-latest'));
      expect(GeminiService.defaultCandidateModels, contains('gemini-3.8-flash'));
      expect(GeminiService.defaultCandidateModels, contains('gemini-2.5-flash-lite'));
    });

    test('respects custom candidate models and custom initial model', () {
      final service = GeminiService(
        apiKey: 'dummy_key',
        modelName: 'gemini-3.8-flash',
        candidateModels: ['gemini-3.8-flash', 'gemini-2.5-flash'],
      );
      expect(service.activeModelName, 'gemini-3.8-flash');
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
  });
}
