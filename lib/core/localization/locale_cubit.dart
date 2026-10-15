import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<Locale> {
  static const String _localeKey = 'app_locale_code';
  final SharedPreferences? _prefs;

  LocaleCubit({SharedPreferences? prefs})
      : _prefs = prefs,
        super(_loadInitialLocale(prefs));

  /// Priority:
  ///   1. Saved user preference (SharedPreferences)
  ///   2. Device system locale (PlatformDispatcher)
  ///   3. English fallback
  static Locale _loadInitialLocale(SharedPreferences? prefs) {
    if (prefs != null) {
      final savedCode = prefs.getString(_localeKey);
      if (savedCode == 'ar') return const Locale('ar');
      if (savedCode == 'en') return const Locale('en');
    }
    // No saved preference — use the device's primary locale.
    final deviceLocale = PlatformDispatcher.instance.locale;
    if (deviceLocale.languageCode == 'ar') return const Locale('ar');
    return const Locale('en');
  }

  bool get isArabic => state.languageCode == 'ar';
  String get languageCode => state.languageCode;

  Future<void> setLocale(Locale locale) async {
    if (state == locale) return;
    emit(locale);
    if (_prefs != null) {
      await _prefs.setString(_localeKey, locale.languageCode);
    }
  }

  Future<void> toggleLocale() async {
    if (isArabic) {
      await setLocale(const Locale('en'));
    } else {
      await setLocale(const Locale('ar'));
    }
  }
}
