class Validators {
  static const int maxTitleLength = 100;
  static const int maxBodyLength = 5000;

  static String? validateTitle(String? value, {bool isArabic = false}) {
    final title = value?.trim() ?? '';

    if (title.isEmpty) {
      return isArabic ? 'لا يمكن أن يكون العنوان فارغاً' : 'Title cannot be empty';
    }

    if (title.length > maxTitleLength) {
      return isArabic
          ? 'لا يمكن أن يتجاوز العنوان $maxTitleLength حرفاً'
          : 'Title cannot exceed $maxTitleLength characters';
    }

    return null;
  }

  static String? validateBody(
    String? value, {
    bool isChecklist = false,
    bool hasAudio = false,
    bool isArabic = false,
  }) {
    final body = value?.trim() ?? '';

    if (body.isEmpty) {
      if (isChecklist || hasAudio) return null;
      return isArabic ? 'لا يمكن أن يكون المحتوى فارغاً' : 'Body cannot be empty';
    }

    if (body.length > maxBodyLength) {
      return isArabic
          ? 'لا يمكن أن يتجاوز المحتوى $maxBodyLength حرفاً'
          : 'Body cannot exceed $maxBodyLength characters';
    }

    return null;
  }

  static String? validateNote({
    required String? title,
    required String? body,
    bool isArabic = false,
  }) {
    return validateTitle(title, isArabic: isArabic) ??
        validateBody(body, isArabic: isArabic);
  }
}
