import 'dart:convert';
import 'dart:typed_data';

import 'package:google_generative_ai/google_generative_ai.dart';

enum GeminiErrorKind {
  emptyInput,
  rateLimit,
  apiKeyMissingOrInvalid,
  network,
  serviceUnavailable,
  unknown,
}

class GeminiService {
  static const String _defaultApiKey =
      String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

  /// Candidate Gemini models ordered by priority.
  /// Strictly restricted to free/economical models (gemini-2.5-flash and gemini-2.5-flash-lite)
  /// so it never consumes or exhausts the developer's personal gemini-3.8-flash quota.
  static const List<String> defaultCandidateModels = [
    'gemini-2.5-flash-native-audio-dialog',
    'gemini-2.5-flash',
    'gemini-3.8-live',
    'gemini-3-flash-live',
    'gemini-2.5-flash-lite',
  ];

  final String _apiKey;
  final List<String> _candidateModels;
  String _activeModelName;

  GeminiService({
    String? apiKey,
    String? modelName,
    List<String>? candidateModels,
  })  : _apiKey = apiKey ?? _defaultApiKey,
        _candidateModels = candidateModels ?? defaultCandidateModels,
        _activeModelName = modelName ?? (candidateModels ?? defaultCandidateModels).first;

  /// Returns true if an API key has been supplied.
  bool get isConfigured => _apiKey.trim().isNotEmpty;

  /// Returns the current active model identifier.
  String get activeModelName => _activeModelName;

  /// Converts any caught error into a friendly, human-readable message tailored
  /// to the user's language without leaking raw API details or stack traces.
  static String getUserFriendlyError(dynamic error, {required bool isArabic}) {
    if (error is GeminiException) {
      return error.localizedMessage(isArabic);
    }
    final str = error.toString().toLowerCase();
    if (str.contains('socket') ||
        str.contains('network') ||
        str.contains('connection') ||
        str.contains('handshake') ||
        str.contains('timeout')) {
      return isArabic
          ? 'تعذر الاتصال بالإنترنت. يرجى التحقق من اتصالك والمحاولة مجدداً.'
          : 'No internet connection. Please check your network and try again.';
    }
    if (str.contains('quota') || str.contains('resource_exhausted') || str.contains('429')) {
      return isArabic
          ? 'تم تجاوز الحد المسموح للاستخدام مؤقتاً. يرجى الانتظار لحظة والمحاولة مجدداً.'
          : 'AI rate limit reached. Please wait a moment and try again.';
    }
    if (str.contains('not found') ||
        str.contains('not supported') ||
        str.contains('modelservice') ||
        str.contains('404')) {
      return isArabic
          ? 'خدمة الذكاء الاصطناعي قيد التحديث حالياً. يرجى المحاولة بعد قليل.'
          : 'AI service is temporarily updating. Please try again shortly.';
    }
    return isArabic
        ? 'تعذر إتمام العملية بواسطة الذكاء الاصطناعي. يرجى المحاولة مرة أخرى.'
        : 'Unable to complete AI operation. Please try again.';
  }

  /// Executes generateContent with resilient fallback across candidate models
  /// in case the current model is retired or unavailable.
  Future<GenerateContentResponse> _generateWithFallback(
    List<Content> contents,
  ) async {
    if (!isConfigured) {
      throw const GeminiException(
        'Gemini AI requires an API key.',
        kind: GeminiErrorKind.apiKeyMissingOrInvalid,
        userFriendlyMessageAr:
            'ميزة الذكاء الاصطناعي تتطلب مفتاح تشغيل (API Key). يرجى إعداد المفتاح.',
        userFriendlyMessageEn:
            'AI features require an API key to operate. Please configure your key.',
      );
    }

    final modelsToTry = [
      _activeModelName,
      ..._candidateModels.where((m) => m != _activeModelName),
    ];

    GenerativeAIException? lastNotFoundException;

    for (int i = 0; i < modelsToTry.length; i++) {
      final currentModel = modelsToTry[i];
      try {
        final client = GenerativeModel(
          model: currentModel,
          apiKey: _apiKey,
        );
        final response = await client.generateContent(contents);
        _activeModelName = currentModel;
        return response;
      } on GenerativeAIException catch (e) {
        final msg = e.message.toLowerCase();
        final isModelNotFound = msg.contains('not found') ||
            msg.contains('not supported') ||
            msg.contains('404') ||
            msg.contains('modelservice.listmodels');

        if (isModelNotFound && i < modelsToTry.length - 1) {
          lastNotFoundException = e;
          continue;
        }
        _translateAndThrow(e);
      } catch (e) {
        if (e is GeminiException) rethrow;
        final errString = e.toString().toLowerCase();
        if (errString.contains('socket') ||
            errString.contains('network') ||
            errString.contains('connection') ||
            errString.contains('handshake') ||
            errString.contains('timeout')) {
          throw const GeminiException(
            'No internet connection. Please check your network and try again.',
            kind: GeminiErrorKind.network,
            userFriendlyMessageAr:
                'تعذر الاتصال بالإنترنت. يرجى التحقق من اتصالك والمحاولة مجدداً.',
            userFriendlyMessageEn:
                'No internet connection. Please check your network and try again.',
          );
        }
        throw GeminiException(
          'AI processing failed: $e',
          kind: GeminiErrorKind.unknown,
          userFriendlyMessageAr:
              'تعذر إتمام المعالجة بواسطة الذكاء الاصطناعي. يرجى المحاولة لاحقاً.',
          userFriendlyMessageEn:
              'AI processing failed. Please try again later.',
        );
      }
    }

    if (lastNotFoundException != null) {
      _translateAndThrow(lastNotFoundException);
    }
    throw const GeminiException(
      'Unable to reach Gemini AI models.',
      kind: GeminiErrorKind.serviceUnavailable,
      userFriendlyMessageAr:
          'خدمة الذكاء الاصطناعي غير متوفرة حالياً. يرجى المحاولة لاحقاً.',
      userFriendlyMessageEn:
          'AI service is currently unavailable. Please try again later.',
    );
  }

  Never _translateAndThrow(GenerativeAIException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('quota') ||
        msg.contains('resource_exhausted') ||
        msg.contains('429')) {
      throw const GeminiException(
        'AI rate limit reached. Please wait a moment and try again.',
        kind: GeminiErrorKind.rateLimit,
        userFriendlyMessageAr:
            'تم تجاوز الحد المسموح للاستخدام مؤقتاً. يرجى الانتظار لحظة والمحاولة مجدداً.',
        userFriendlyMessageEn:
            'AI rate limit reached. Please wait a moment and try again.',
      );
    }
    if (msg.contains('api key') ||
        msg.contains('unauthorized') ||
        msg.contains('forbidden')) {
      throw const GeminiException(
        'Invalid API configuration. Please verify your Gemini API key.',
        kind: GeminiErrorKind.apiKeyMissingOrInvalid,
        userFriendlyMessageAr:
            'خدمة الذكاء الاصطناعي غير مفعلة أو المفتاح غير صالح.',
        userFriendlyMessageEn:
            'AI service configuration is invalid. Please verify your API key.',
      );
    }
    if (msg.contains('not found') ||
        msg.contains('not supported') ||
        msg.contains('modelservice.listmodels') ||
        msg.contains('404')) {
      throw const GeminiException(
        'Gemini model is temporarily unavailable. Please try again later.',
        kind: GeminiErrorKind.serviceUnavailable,
        userFriendlyMessageAr:
            'خدمة الذكاء الاصطناعي قيد التحديث حالياً. يرجى المحاولة بعد قليل.',
        userFriendlyMessageEn:
            'AI model service is temporarily updating. Please try again shortly.',
      );
    }
    throw GeminiException(
      'Gemini error: ${e.message}',
      kind: GeminiErrorKind.unknown,
      userFriendlyMessageAr:
          'تعذر إتمام العملية بواسطة الذكاء الاصطناعي حالياً. يرجى المحاولة مرة أخرى.',
      userFriendlyMessageEn:
          'Unable to complete AI operation right now. Please try again.',
    );
  }

  /// Summarizes a note's text content concisely in the note's native language.
  Future<String> summarizeNote({
    required String title,
    required String body,
  }) async {
    final cleanBody = body.trim();
    if (cleanBody.isEmpty) {
      throw const GeminiException(
        'Note content is empty. Add some text to summarize.',
        kind: GeminiErrorKind.emptyInput,
        userFriendlyMessageAr: 'محتوى الملاحظة فارغ. اكتب نصاً ليتم تلخيصه.',
        userFriendlyMessageEn: 'Note content is empty. Add some text to summarize.',
      );
    }

    final prompt = '''
You are a fast, high-quality note assistant for the QuickNotes app.
Summarize the following note clearly and concisely in 1 to 3 sentences or bullet points.
- Highlight the most important decisions, action items, or core takeaways.
- Respond in the same language as the note content (e.g. Arabic if the note is Arabic, English if English).
- Do not output preamble, pleasantries, or meta commentary (e.g. avoid "Here is your summary:"). Just output the summary directly.

${title.trim().isNotEmpty ? 'Note Title: ${title.trim()}\n' : ''}
Note Content:
$cleanBody
''';

    try {
      final response = await _generateWithFallback([
        Content.text(prompt),
      ]);

      final text = response.text?.trim();
      if (text == null || text.isEmpty) {
        throw const GeminiException(
          'Unable to generate summary. Please try again.',
          kind: GeminiErrorKind.unknown,
          userFriendlyMessageAr: 'تعذر إنشاء الملخص. يرجى المحاولة مرة أخرى.',
          userFriendlyMessageEn: 'Unable to generate summary. Please try again.',
        );
      }

      return text;
    } catch (e) {
      if (e is GeminiException) rethrow;
      throw GeminiException(
        '$e',
        kind: GeminiErrorKind.unknown,
      );
    }
  }

  /// Suggests 2 to 5 concise categorical tags based on note content.
  Future<List<String>> suggestTags({
    required String title,
    required String body,
  }) async {
    final cleanBody = body.trim();
    final cleanTitle = title.trim();
    if (cleanBody.isEmpty && cleanTitle.isEmpty) {
      return [];
    }

    final prompt = '''
You are a smart categorizer for QuickNotes.
Analyze the following note and suggest 2 to 5 short, relevant category tags (e.g., Work, Personal, Ideas, Finance, Study, Shopping, Meeting, Health, Urgent).
- If the note is in Arabic, provide Arabic tags (e.g. عمل, شخصي, أفكار, تسوق, دراسة, عاجل).
- If English, provide English tags.
- Return ONLY a comma-separated list of tag names without hashtags, bullet points, numbers, or quotes.
Example: Work, Meeting, Important

${cleanTitle.isNotEmpty ? 'Title: $cleanTitle\n' : ''}
Content:
$cleanBody
''';

    try {
      final response = await _generateWithFallback([
        Content.text(prompt),
      ]);

      final text = response.text?.trim();
      if (text == null || text.isEmpty) return [];

      return text
          .split(RegExp(r'[,،\n]'))
          .map((t) => t.replaceAll(RegExp(r'[#\-"*•]'), '').trim())
          .where((t) => t.isNotEmpty && t.length <= 25)
          .take(5)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Extracts actionable tasks and detected deadlines from note text.
  Future<List<String>> extractTasks({
    required String title,
    required String body,
  }) async {
    final cleanBody = body.trim();
    if (cleanBody.isEmpty) return [];

    final prompt = '''
You are an expert productivity assistant for QuickNotes.
Analyze the following note text and extract all concrete action items, to-dos, and tasks.
- If a deadline, date, or time is mentioned (e.g. "by 5 PM", "tomorrow", "next Monday"), include it explicitly in the task title (e.g. "Send email (by tomorrow 5 PM)").
- Return ONLY a plain list of tasks, one task per line.
- Do NOT include numbering, bullet symbols (*, -, •), or markdown headers. Just one task string per line.
- Match the language of the note (Arabic or English).

${title.trim().isNotEmpty ? 'Title: ${title.trim()}\n' : ''}
Content:
$cleanBody
''';

    try {
      final response = await _generateWithFallback([
        Content.text(prompt),
      ]);

      final text = response.text?.trim();
      if (text == null || text.isEmpty) return [];

      return text
          .split('\n')
          .map((line) => line.replaceAll(RegExp(r'^[\d\.\-\*•\[\]x\s]+'), '').trim())
          .where((line) => line.isNotEmpty)
          .toList();
    } catch (e) {
      if (e is GeminiException) rethrow;
      throw GeminiException('$e', kind: GeminiErrorKind.unknown);
    }
  }

  /// Evaluates a list of notes against a natural language search query and returns the matching note IDs ordered by relevance.
  Future<List<int>> semanticSearch({
    required String query,
    required List<Map<String, dynamic>> notesSummary,
  }) async {
    if (query.trim().isEmpty || notesSummary.isEmpty) return [];

    final noteSnippets = notesSummary.map((n) {
      final id = n['id'];
      final title = n['title'] ?? '';
      final body = n['body'] ?? '';
      final tasks = n['tasks'] ?? '';
      final snippet = '$title - $body ${tasks.isNotEmpty ? "Tasks: $tasks" : ""}';
      final clean = snippet.length > 180 ? '${snippet.substring(0, 180)}...' : snippet;
      return 'ID: $id | Content: $clean';
    }).join('\n');

    final prompt = '''
You are a semantic search engine for a notes app.
Given the user's natural language search query, identify which notes match the meaning, context, or intent of the query.
Query: "${query.trim()}"

Notes list:
$noteSnippets

Return ONLY the IDs of the matching notes, comma-separated, ordered by best match first.
If no notes match, return NONE.
Example format: 4, 12, 1
''';

    try {
      final response = await _generateWithFallback([
        Content.text(prompt),
      ]);

      final text = response.text?.trim();
      if (text == null || text.isEmpty || text.toUpperCase().contains('NONE')) {
        return [];
      }

      final matches = RegExp(r'\d+').allMatches(text);
      return matches
          .map((m) => int.tryParse(m.group(0)!))
          .whereType<int>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Extracts note title, body, and tasks from an image using Gemini Multimodal Vision (OCR).
  Future<Map<String, dynamic>> extractNoteFromImage({
    required Uint8List imageBytes,
    String mimeType = 'image/jpeg',
  }) async {
    final prompt = '''
You are an expert OCR and intelligent document scanner for QuickNotes, with full native support for both Arabic (العربية) and English.
Extract all visible text from this image (handwritten note, document, receipt, whiteboard, screen, etc.).

CRITICAL LANGUAGE & OCR RULES:
1. NATIVE ARABIC SUPPORT: If the image contains Arabic text (handwritten or printed), extract the exact Arabic text verbatim in proper Arabic script (استخراج النص العربي بدقة تامة وبنفس الصياغة).
2. DO NOT TRANSLATE: Never translate Arabic text into English or vice-versa. Always preserve the original language exactly as written.
3. BILINGUAL / MIXED SUPPORT: If the image contains both Arabic and English text, preserve both languages faithfully as they appear in the image.
4. TITLE GENERATION:
   - If the note has an explicit title, extract it.
   - If no title is present, generate a concise descriptive title (max 6 words) in the SAME language as the note content (Arabic if content is Arabic, English if content is English).
5. TASKS EXTRACTION:
   - If the image contains a list of tasks, action items, or checkboxes, extract them into the "tasks" array in their original language.
6. Return ONLY valid raw JSON with no backticks, no markdown codeblocks, and no preamble:

{
  "title": "...",
  "body": "...",
  "tasks": ["...", "..."]
}
''';

    try {
      final response = await _generateWithFallback([
        Content.multi([
          TextPart(prompt),
          DataPart(mimeType, imageBytes),
        ]),
      ]);

      final text = response.text?.trim() ?? '';
      final jsonStart = text.indexOf('{');
      final jsonEnd = text.lastIndexOf('}');
      if (jsonStart != -1 && jsonEnd != -1) {
        final jsonStr = text.substring(jsonStart, jsonEnd + 1);
        final decoded = json.decode(jsonStr) as Map<String, dynamic>;
        return {
          'title': decoded['title']?.toString().trim() ?? '',
          'body': decoded['body']?.toString().trim() ?? '',
          'tasks': (decoded['tasks'] as List<dynamic>?)
                  ?.map((t) => t.toString().trim())
                  .toList() ??
              <String>[],
        };
      }

      return {
        'title': 'Scanned Note',
        'body': text,
        'tasks': <String>[],
      };
    } catch (e) {
      if (e is GeminiException) rethrow;
      throw GeminiException('Failed to scan image: $e', kind: GeminiErrorKind.unknown);
    }
  }
}

class GeminiException implements Exception {
  final String message;
  final GeminiErrorKind kind;
  final String? userFriendlyMessageAr;
  final String? userFriendlyMessageEn;

  const GeminiException(
    this.message, {
    this.kind = GeminiErrorKind.unknown,
    this.userFriendlyMessageAr,
    this.userFriendlyMessageEn,
  });

  /// Returns the localized, end-user friendly error message.
  String localizedMessage(bool isArabic) {
    if (isArabic) {
      return userFriendlyMessageAr ?? _defaultArabic(kind);
    } else {
      return userFriendlyMessageEn ?? _defaultEnglish(kind);
    }
  }

  static String _defaultArabic(GeminiErrorKind kind) {
    switch (kind) {
      case GeminiErrorKind.emptyInput:
        return 'محتوى الملاحظة فارغ. يرجى إضافة نص أولاً.';
      case GeminiErrorKind.rateLimit:
        return 'تم تجاوز الحد المسموح للاستخدام مؤقتاً. يرجى الانتظار لحظة والمحاولة مجدداً.';
      case GeminiErrorKind.apiKeyMissingOrInvalid:
        return 'خدمة الذكاء الاصطناعي غير مفعلة أو المفتاح غير صالح.';
      case GeminiErrorKind.network:
        return 'تعذر الاتصال بالإنترنت. يرجى التحقق من اتصالك والمحاولة مجدداً.';
      case GeminiErrorKind.serviceUnavailable:
        return 'خدمة الذكاء الاصطناعي قيد التحديث حالياً. يرجى المحاولة بعد قليل.';
      case GeminiErrorKind.unknown:
        return 'تعذر إتمام العملية بواسطة الذكاء الاصطناعي. يرجى المحاولة مرة أخرى.';
    }
  }

  static String _defaultEnglish(GeminiErrorKind kind) {
    switch (kind) {
      case GeminiErrorKind.emptyInput:
        return 'Note content is empty. Please add some text first.';
      case GeminiErrorKind.rateLimit:
        return 'AI rate limit reached. Please wait a moment and try again.';
      case GeminiErrorKind.apiKeyMissingOrInvalid:
        return 'AI service configuration is invalid. Please verify your API key.';
      case GeminiErrorKind.network:
        return 'No internet connection. Please check your network and try again.';
      case GeminiErrorKind.serviceUnavailable:
        return 'AI model service is temporarily updating. Please try again shortly.';
      case GeminiErrorKind.unknown:
        return 'Unable to complete AI operation. Please try again.';
    }
  }

  @override
  String toString() => message;
}
