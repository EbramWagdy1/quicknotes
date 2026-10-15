import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quicknotes/core/localization/locale_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocaleCubit Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('initial state defaults to English when no preference is saved', () async {
      final prefs = await SharedPreferences.getInstance();
      final cubit = LocaleCubit(prefs: prefs);

      expect(cubit.state, equals(const Locale('en')));
      expect(cubit.isArabic, isFalse);
      expect(cubit.languageCode, equals('en'));
      await cubit.close();
    });

    test('initial state loads saved Arabic preference from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'app_locale_code': 'ar'});
      final prefs = await SharedPreferences.getInstance();
      final cubit = LocaleCubit(prefs: prefs);

      expect(cubit.state, equals(const Locale('ar')));
      expect(cubit.isArabic, isTrue);
      expect(cubit.languageCode, equals('ar'));
      await cubit.close();
    });

    test('setLocale updates state and persists preference', () async {
      final prefs = await SharedPreferences.getInstance();
      final cubit = LocaleCubit(prefs: prefs);

      await cubit.setLocale(const Locale('ar'));
      expect(cubit.state, equals(const Locale('ar')));
      expect(cubit.isArabic, isTrue);
      expect(prefs.getString('app_locale_code'), equals('ar'));

      await cubit.setLocale(const Locale('en'));
      expect(cubit.state, equals(const Locale('en')));
      expect(cubit.isArabic, isFalse);
      expect(prefs.getString('app_locale_code'), equals('en'));

      await cubit.close();
    });

    test('toggleLocale switches between English and Arabic', () async {
      final prefs = await SharedPreferences.getInstance();
      final cubit = LocaleCubit(prefs: prefs);

      expect(cubit.state, equals(const Locale('en')));

      await cubit.toggleLocale();
      expect(cubit.state, equals(const Locale('ar')));
      expect(cubit.isArabic, isTrue);
      expect(prefs.getString('app_locale_code'), equals('ar'));

      await cubit.toggleLocale();
      expect(cubit.state, equals(const Locale('en')));
      expect(cubit.isArabic, isFalse);
      expect(prefs.getString('app_locale_code'), equals('en'));

      await cubit.close();
    });
  });
}
