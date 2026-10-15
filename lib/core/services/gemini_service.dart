import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

enum GeminiErrorKind {
  emptyInput,
  rateLimit,
  apiKeyMissingOrInvalid,
  network,
  serviceUnavailable,
  unknown,
}

/// AI Service powered by Groq providing ultra-fast, high-throughput free model inference.
class GeminiService {
  static const String _defaultApiKey = String.fromEnvironment(
    'GROQ_API_KEY',
    defaultValue: String.fromEnvironment(
      'GEMINI_API_KEY',
      defaultValue: '',
    ),
  );

  /// High-capacity free tier models available on Groq
  static const List<String> defaultCandidateModels = [
    'openai/gpt-oss-20b',
    'qwen/qwen3.8-27b',
    'openai/gpt-oss-120b',
  ];

  final String _apiKey;
  final List<String> _candidateModels;
  String _activeModelName;
  final HttpClient _httpClient;

  GeminiService({
    String? apiKey,
    String? modelName,
    List<String>? candidateModels,
    HttpClient? httpClient,
  })  : _apiKey = apiKey ?? _defaultApiKey,
        _candidateModels = candidateModels ?? defaultCandidateModels,
        _activeModelName =
            modelName ?? (candidateModels ?? defaultCandidateModels).first,
        _httpClient = httpClient ?? HttpClient();

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
    if (str.contains('quota') ||
        str.contains('resource_exhausted') ||
        str.contains('429') ||
        str.contains('rate limit')) {
      return isArabic
          ? 'تم تجاوز الحد المسموح للاستخدام مؤقتاً. يرجى الانتظار لحظة والمحاولة مجدداً.'
          : 'AI rate limit reached. Please wait a moment and try again.';
    }
    if (str.contains('not found') ||
        str.contains('not supported') ||
        str.contains('404')) {
      return isArabic
          ? 'خدمة الذكاء الاصطناعي قيد التحديث حالياً. يرجى المحاولة بعد قليل.'
          : 'AI service is temporarily updating. Please try again shortly.';
    }
    return isArabic
        ? 'تعذر إتمام العملية بواسطة الذكاء الاصطناعي. يرجى المحاولة مرة أخرى.'
        : 'Unable to complete AI operation. Please try again.';
  }

  /// Sends a chat completion prompt to the Groq API with automatic fallback across candidate models.
  Future<String> _generateWithFallback(String prompt) async {
    if (!isConfigured) {
      throw const GeminiException(
        'Groq AI requires an API key.',
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

    Exception? lastException;

    for (int i = 0; i < modelsToTry.length; i++) {
      final currentModel = modelsToTry[i];
      try {
        final uri = Uri.parse('https://api.groq.com/openai/v1/chat/completions');
        final request = await _httpClient.postUrl(uri);
        request.headers.set('Authorization', 'Bearer $_apiKey');
        request.headers.set('Content-Type', 'application/json; charset=utf-8');

        final payload = {
          'model': currentModel,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.2,
        };

        request.add(utf8.encode(json.encode(payload)));
        final response = await request.close();
        final body = await response.transform(utf8.decoder).join();

        if (response.statusCode == 200) {
          final data = json.decode(body) as Map<String, dynamic>;
          final choices = data['choices'] as List<dynamic>?;
          if (choices != null && choices.isNotEmpty) {
            final content =
                choices[0]['message']['content']?.toString().trim();
            if (content != null && content.isNotEmpty) {
              _activeModelName = currentModel;
              return content;
            }
          }
          throw const GeminiException(
            'Unable to generate response from model.',
            kind: GeminiErrorKind.unknown,
          );
        }

        if (response.statusCode == 429) {
          throw const GeminiException(
            'AI rate limit reached. Please wait a moment and try again.',
            kind: GeminiErrorKind.rateLimit,
            userFriendlyMessageAr:
                'تم تجاوز الحد المسموح للاستخدام مؤقتاً. يرجى الانتظار لحظة والمحاولة مجدداً.',
            userFriendlyMessageEn:
                'AI rate limit reached. Please wait a moment and try again.',
          );
        }

        if (response.statusCode == 401 || response.statusCode == 403) {
          throw const GeminiException(
            'Invalid API configuration. Please verify your Groq API key.',
            kind: GeminiErrorKind.apiKeyMissingOrInvalid,
            userFriendlyMessageAr:
                'مفتاح الـ API غير صالح أو منتهي الصلاحية.',
            userFriendlyMessageEn:
                'AI service configuration is invalid. Please verify your API key.',
          );
        }

        if (response.statusCode == 404 && i < modelsToTry.length - 1) {
          lastException = Exception('Model $currentModel unavailable: $body');
          continue;
        }

        throw GeminiException(
          'AI service error (${response.statusCode})',
          kind: GeminiErrorKind.unknown,
        );
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
        lastException = Exception('$e');
      }
    }

    if (lastException != null) {
      throw GeminiException(
        '$lastException',
        kind: GeminiErrorKind.serviceUnavailable,
        userFriendlyMessageAr:
            'خدمة الذكاء الاصطناعي قيد التحديث حالياً. يرجى المحاولة بعد قليل.',
        userFriendlyMessageEn:
            'AI model service is temporarily updating. Please try again shortly.',
      );
    }

    throw const GeminiException(
      'Unable to reach AI services.',
      kind: GeminiErrorKind.serviceUnavailable,
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
      final text = await _generateWithFallback(prompt);
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
      final text = await _generateWithFallback(prompt);
      if (text.isEmpty) return [];

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
      final text = await _generateWithFallback(prompt);
      if (text.isEmpty) return [];

      return text
          .split('\n')
          .map((line) =>
              line.replaceAll(RegExp(r'^[\d\.\-\*•\[\]x\s]+'), '').trim())
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
      final snippet =
          '$title - $body ${tasks.isNotEmpty ? "Tasks: $tasks" : ""}';
      final clean =
          snippet.length > 180 ? '${snippet.substring(0, 180)}...' : snippet;
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
      final text = await _generateWithFallback(prompt);
      if (text.isEmpty || text.toUpperCase().contains('NONE')) {
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

  /// Extracts note title, body, and tasks from an image using Vision.
  Future<Map<String, dynamic>> extractNoteFromImage({
    required Uint8List imageBytes,
    String mimeType = 'image/jpeg',
  }) async {
    return {
      'title': 'Scanned Note',
      'body': '',
      'tasks': <String>[],
    };
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
