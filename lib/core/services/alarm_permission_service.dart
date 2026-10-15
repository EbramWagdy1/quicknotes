import 'dart:io';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlarmPermissionService {
  static const MethodChannel _channel =
      MethodChannel('com.ebramwagdy.quicknotes/alarm_permissions');

  static const String _prefPromptKey = 'has_seen_alarm_permission_prompt_v1';

  final SharedPreferences? prefs;

  AlarmPermissionService({this.prefs});

  /// Check if the app is currently whitelisted / ignoring battery optimizations
  Future<bool> isIgnoringBatteryOptimizations() async {
    if (!Platform.isAndroid) return true;
    try {
      final bool? isIgnoring =
          await _channel.invokeMethod<bool>('isIgnoringBatteryOptimizations');
      return isIgnoring ?? false;
    } catch (_) {
      return true;
    }
  }

  /// Request the system to whitelist the app from battery optimizations
  Future<bool> requestIgnoreBatteryOptimizations() async {
    if (!Platform.isAndroid) return true;
    try {
      final bool? result =
          await _channel.invokeMethod<bool>('requestIgnoreBatteryOptimizations');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Open Android App Details Settings page
  Future<void> openAppSettings() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>('openAppSettings');
    } catch (_) {}
  }

  /// Open OEM-specific permissions page (MIUI / ColorOS / FuntouchOS / OneUI)
  Future<void> openOemPermissions() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>('openOemPermissions');
    } catch (_) {
      await openAppSettings();
    }
  }

  /// Get manufacturer name
  Future<String> getDeviceManufacturer() async {
    if (!Platform.isAndroid) return '';
    try {
      final String? manufacturer =
          await _channel.invokeMethod<String>('getDeviceManufacturer');
      return manufacturer ?? '';
    } catch (_) {
      return '';
    }
  }

  /// Check if device belongs to an OEM with aggressive battery or background restrictions
  Future<bool> isOemDevice() async {
    if (!Platform.isAndroid) return false;
    final manufacturer = (await getDeviceManufacturer()).toLowerCase();
    return manufacturer.contains('xiaomi') ||
        manufacturer.contains('redmi') ||
        manufacturer.contains('poco') ||
        manufacturer.contains('samsung') ||
        manufacturer.contains('oppo') ||
        manufacturer.contains('realme') ||
        manufacturer.contains('vivo') ||
        manufacturer.contains('huawei') ||
        manufacturer.contains('honor');
  }

  /// Check if we should proactively prompt the user on startup
  Future<bool> shouldShowPrompt() async {
    if (!Platform.isAndroid) return false;
    final seen = prefs?.getBool(_prefPromptKey) ?? false;
    if (seen) return false;

    final isIgnoring = await isIgnoringBatteryOptimizations();
    // If not yet unrestricted, we should show the prompt
    return !isIgnoring;
  }

  /// Mark the prompt as seen so we don't annoy the user on every launch
  Future<void> markPromptSeen() async {
    await prefs?.setBool(_prefPromptKey, true);
  }

  /// Move QuickNotes task to the background so the user returns to their previous app/screen
  Future<void> closeAlarm() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>('closeAlarm');
    } catch (_) {
      try {
        await SystemNavigator.pop();
      } catch (_) {}
    }
  }
}
