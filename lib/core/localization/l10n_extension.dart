import 'package:flutter/material.dart';
import 'package:quicknotes/core/localization/generated/app_localizations.dart';
import 'package:quicknotes/core/utils/date_formatter.dart';

extension LocalizationContextExtension on BuildContext {
  AppLocalizations get l10n =>
      AppLocalizations.of(this) ??
      lookupAppLocalizations(const Locale('en'));

  String get languageCode => Localizations.localeOf(this).languageCode;

  bool get isArabic => languageCode == 'ar';

  String formatDate(DateTime date) =>
      DateFormatter.format(date, locale: isArabic ? 'ar' : 'en');

  String formatReminder(DateTime date) =>
      DateFormatter.formatReminder(date, locale: isArabic ? 'ar' : 'en');
}
