import 'package:flutter_test/flutter_test.dart';
import 'package:quicknotes/core/services/gemini_service.dart';

void main() {
  group('GeminiService Unit Tests', () {
    test('throws GeminiException when body is empty or whitespace', () async {
      final service = GeminiService(apiKey: 'dummy_key');

      expect(
        () => service.summarizeNote(title: 'Empty Note', body: '   '),
        throwsA(isA<GeminiException>().having(
          (e) => e.message,
          'message',
          contains('empty'),
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
          (e) => e.message,
          'message',
          contains('API key'),
        )),
      );
    });

    test('GeminiException toString returns message', () {
      const ex = GeminiException('Custom error');
      expect(ex.toString(), 'Custom error');
      expect(ex.message, 'Custom error');
    });
  });
}
