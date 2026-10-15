import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;

  bool get isListening => _speech.isListening;
  bool get isInitialized => _isInitialized;

  ValueChanged<String>? onStatusChange;
  ValueChanged<String>? onErrorChange;

  Future<bool> initialize({
    ValueChanged<String>? onError,
    ValueChanged<String>? onStatus,
  }) async {
    if (_isInitialized) return true;
    try {
      _isInitialized = await _speech.initialize(
        onError: (val) {
          debugPrint('SpeechService error: ${val.errorMsg}');
          onError?.call(val.errorMsg);
          onErrorChange?.call(val.errorMsg);
        },
        onStatus: (val) {
          debugPrint('SpeechService status: $val');
          onStatus?.call(val);
          onStatusChange?.call(val);
        },
        debugLogging: false,
      );
      return _isInitialized;
    } catch (e) {
      debugPrint('SpeechService initialization error: $e');
      return false;
    }
  }

  /// Returns all available speech locales on the device.
  Future<List<stt.LocaleName>> getLocales() async {
    final ready = await initialize();
    if (!ready) return [];
    try {
      return await _speech.locales();
    } catch (_) {
      return [];
    }
  }

  /// Resolves the best localeId for Arabic ('ar') or English ('en').
  Future<String?> resolveLocale(String languageCode) async {
    final locales = await getLocales();
    if (locales.isEmpty) {
      return languageCode == 'ar' ? 'ar_SA' : 'en_US';
    }

    if (languageCode == 'ar') {
      // Prioritize Egyptian Arabic (ar_EG), Saudi (ar_SA), or any Arabic locale
      final arEg = locales.where((l) => l.localeId == 'ar_EG' || l.localeId == 'ar-EG').firstOrNull;
      if (arEg != null) return arEg.localeId;
      final arSa = locales.where((l) => l.localeId == 'ar_SA' || l.localeId == 'ar-SA').firstOrNull;
      if (arSa != null) return arSa.localeId;
      final anyAr = locales.where((l) => l.localeId.toLowerCase().startsWith('ar')).firstOrNull;
      return anyAr?.localeId ?? 'ar_SA';
    } else {
      final enUs = locales.where((l) => l.localeId == 'en_US' || l.localeId == 'en-US').firstOrNull;
      if (enUs != null) return enUs.localeId;
      final anyEn = locales.where((l) => l.localeId.toLowerCase().startsWith('en')).firstOrNull;
      return anyEn?.localeId ?? 'en_US';
    }
  }

  Future<void> startListening({
    required ValueChanged<String> onResult,
    String? localeId,
    VoidCallback? onDone,
    ValueChanged<String>? onError,
  }) async {
    final ready = await initialize(
      onError: onError,
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          onDone?.call();
        }
      },
    );
    if (!ready) {
      throw const SpeechException(
        'Speech recognition is unavailable or microphone permission was denied. Please check microphone permissions in settings.',
      );
    }

    try {
      await _speech.listen(
        onResult: (result) {
          if (result.recognizedWords.isNotEmpty) {
            onResult(result.recognizedWords);
          }
        },
        listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          cancelOnError: false,
          listenMode: stt.ListenMode.dictation,
          localeId: localeId,
        ),
      );
    } catch (e) {
      throw SpeechException('Failed to start speech recognition: $e');
    }
  }

  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }
}

class SpeechException implements Exception {
  final String message;
  const SpeechException(this.message);

  @override
  String toString() => message;
}
