import 'package:flutter_test/flutter_test.dart';
import 'package:quicknotes/core/services/speech_service.dart';

void main() {
  group('SpeechService Unit Tests', () {
    test('SpeechException stores and returns proper message', () {
      const ex = SpeechException('Microphone permission denied');
      expect(ex.message, 'Microphone permission denied');
      expect(ex.toString(), 'Microphone permission denied');
    });

    test('SpeechService initial state is not listening and not initialized', () {
      final service = SpeechService();
      expect(service.isListening, false);
      expect(service.isInitialized, false);
    });
  });
}
