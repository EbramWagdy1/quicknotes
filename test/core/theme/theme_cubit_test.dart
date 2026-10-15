import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quicknotes/core/theme/theme_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeCubit Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('initial state defaults to ThemeMode.system when no preference is saved', () async {
      final prefs = await SharedPreferences.getInstance();
      final cubit = ThemeCubit(prefs: prefs);

      expect(cubit.state, equals(ThemeMode.system));
      await cubit.close();
    });

    test('initial state loads saved preference from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'app_theme_mode': 'dark'});
      final prefs = await SharedPreferences.getInstance();
      final cubit = ThemeCubit(prefs: prefs);

      expect(cubit.state, equals(ThemeMode.dark));
      await cubit.close();
    });

    test('setThemeMode updates state and persists preference', () async {
      final prefs = await SharedPreferences.getInstance();
      final cubit = ThemeCubit(prefs: prefs);

      await cubit.setThemeMode(ThemeMode.light);
      expect(cubit.state, equals(ThemeMode.light));
      expect(prefs.getString('app_theme_mode'), equals('light'));

      await cubit.setThemeMode(ThemeMode.dark);
      expect(cubit.state, equals(ThemeMode.dark));
      expect(prefs.getString('app_theme_mode'), equals('dark'));

      await cubit.setThemeMode(ThemeMode.system);
      expect(cubit.state, equals(ThemeMode.system));
      expect(prefs.getString('app_theme_mode'), equals('system'));

      await cubit.close();
    });

    test('toggleTheme cycles between light and dark', () async {
      final prefs = await SharedPreferences.getInstance();
      final cubit = ThemeCubit(prefs: prefs);

      await cubit.setThemeMode(ThemeMode.light);
      await cubit.toggleTheme();
      expect(cubit.state, equals(ThemeMode.dark));

      await cubit.toggleTheme();
      expect(cubit.state, equals(ThemeMode.light));

      await cubit.close();
    });
  });
}
