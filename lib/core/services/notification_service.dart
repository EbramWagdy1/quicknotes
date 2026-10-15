import 'dart:developer' as developer;
import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  bool _isInitialized = false;
  int? _initialAlarmNoteId;

  static const String alarmChannelId = 'note_reminders_alarm_channel_v2';
  static const String alarmChannelName = 'Note Reminders & Alarms';
  static const String alarmChannelDesc =
      'Alarm notifications for scheduled note reminders';

  void Function(int noteId, String? actionId)? onAlarmAction;
  void Function(int noteId)? onAlarmTriggered;

  NotificationService({
    FlutterLocalNotificationsPlugin? notificationsPlugin,
    this.onAlarmAction,
    this.onAlarmTriggered,
  }) : _notificationsPlugin =
            notificationsPlugin ?? FlutterLocalNotificationsPlugin();

  bool get isInitialized => _isInitialized;
  int? get initialAlarmNoteId => _initialAlarmNoteId;
  void clearInitialAlarmNoteId() => _initialAlarmNoteId = null;

  /// Get note ID if the app was launched by tapping a notification or fullScreenIntent
  Future<int?> getInitialAlarmNoteId() async {
    if (_initialAlarmNoteId != null) return _initialAlarmNoteId;
    try {
      final details =
          await _notificationsPlugin.getNotificationAppLaunchDetails();
      if (details?.didNotificationLaunchApp ?? false) {
        final payload = details?.notificationResponse?.payload;
        if (payload != null && !payload.startsWith('proximity_')) {
          _initialAlarmNoteId = int.tryParse(payload);
          return _initialAlarmNoteId;
        }
      }
    } catch (_) {}
    return null;
  }

  /// Initialize notifications plugin, alarm channel, and timezone database
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      tz.initializeTimeZones();
      _configureLocalTimezone();

      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const linuxSettings = LinuxInitializationSettings(
        defaultActionName: 'Open notification',
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
        linux: linuxSettings,
      );

      final initialized = await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (details) {
          developer.log(
            'Notification tapped with payload: ${details.payload}, actionId: ${details.actionId}',
            name: 'NotificationService',
          );
          final noteId = int.tryParse(details.payload ?? '');
          if (noteId != null) {
            cancelReminder(noteId);
            onAlarmAction?.call(noteId, details.actionId);
          }
        },
      );

      final launchDetails =
          await _notificationsPlugin.getNotificationAppLaunchDetails();
      if (launchDetails?.didNotificationLaunchApp ?? false) {
        final payload = launchDetails?.notificationResponse?.payload;
        developer.log(
          'Cold launch via notification payload: $payload',
          name: 'NotificationService',
        );
        if (payload != null && !payload.startsWith('proximity_')) {
          _initialAlarmNoteId = int.tryParse(payload);
        }
      }

      final androidPlatform = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlatform != null) {
        final channel = AndroidNotificationChannel(
          alarmChannelId,
          alarmChannelName,
          description: alarmChannelDesc,
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          vibrationPattern:
              Int64List.fromList([0, 1000, 500, 1000, 500, 1000]),
          audioAttributesUsage: AudioAttributesUsage.alarm,
        );
        await androidPlatform.createNotificationChannel(channel);
      }

      _isInitialized = initialized ?? true;
      return _isInitialized;
    } catch (e) {
      developer.log(
        'Failed to initialize NotificationService: $e',
        name: 'NotificationService',
      );
      return false;
    }
  }

  Future<void> _configureLocalTimezone() async {
    try {
      final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      final tzName = timeZoneInfo.identifier;
      try {
        tz.setLocalLocation(tz.getLocation(tzName));
        developer.log('Set local timezone to $tzName',
            name: 'NotificationService');
        return;
      } catch (_) {
        _setFallbackTimezone();
      }
    } catch (e) {
      _setFallbackTimezone();
    }
  }

  void _setFallbackTimezone() {
    try {
      final now = DateTime.now();
      final targetOffset = now.timeZoneOffset;
      for (final location in tz.timeZoneDatabase.locations.values) {
        if (location.currentTimeZone.offset == targetOffset) {
          tz.setLocalLocation(location);
          developer.log('Set fallback timezone by offset: ${location.name}',
              name: 'NotificationService');
          return;
        }
      }
    } catch (_) {}
  }

  /// Request permissions on Android 13+ and iOS
  Future<bool> requestPermissions() async {
    try {
      final androidPlatform = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlatform != null) {
        final granted =
            await androidPlatform.requestNotificationsPermission();
        try {
          final canSchedule =
              await androidPlatform.canScheduleExactNotifications();
          if (canSchedule == false) {
            await androidPlatform.requestExactAlarmsPermission();
          }
        } catch (e) {
          developer.log(
              'Exact alarm permission request failed or unsupported: $e',
              name: 'NotificationService');
        }
        try {
          await androidPlatform.requestFullScreenIntentPermission();
        } catch (e) {
          developer.log(
              'Full-screen intent permission request failed or unsupported: $e',
              name: 'NotificationService');
        }
        if (granted != null) return granted;
      }

      final iosPlatform = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      if (iosPlatform != null) {
        final granted = await iosPlatform.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        if (granted != null) return granted;
      }

      return true;
    } catch (e) {
      developer.log('Permission request error: $e',
          name: 'NotificationService');
      return false;
    }
  }

  AndroidNotificationDetails _buildAlarmNotificationDetails() {
    return AndroidNotificationDetails(
      alarmChannelId,
      alarmChannelName,
      channelDescription: alarmChannelDesc,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000, 500, 1000]),
      audioAttributesUsage: AudioAttributesUsage.alarm,
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: true,
      showWhen: true,
      visibility: NotificationVisibility.public,
      ticker: 'Note Reminder Alarm',
      additionalFlags: Int32List.fromList(<int>[4]), // FLAG_INSISTENT
      actions: const <AndroidNotificationAction>[
        AndroidNotificationAction(
          'in_progress',
          'جاري العمل ⚡',
          showsUserInterface: true,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          'snooze',
          'أجّل 10 دقائق ⏰',
          showsUserInterface: true,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          'dismiss',
          'إيقاف ✕',
          showsUserInterface: true,
          cancelNotification: true,
        ),
      ],
    );
  }

  /// Fire an immediate alarm notification and trigger in-app alarm screen
  Future<bool> triggerImmediateAlarm({
    required int id,
    required String title,
    required String body,
  }) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final androidDetails = _buildAlarmNotificationDetails();
      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      );

      await _notificationsPlugin.show(
        id: id,
        title: title.isNotEmpty ? title : 'Note Reminder ⏰',
        body: body.isNotEmpty ? body : 'You have a scheduled note reminder',
        notificationDetails: notificationDetails,
        payload: id.toString(),
      );

      onAlarmTriggered?.call(id);
      return true;
    } catch (e) {
      developer.log(
        'Error triggering immediate alarm: $e',
        name: 'NotificationService',
      );
      return false;
    }
  }

  /// Schedule a local reminder for a note with Alarm behavior
  Future<bool> scheduleNoteReminder({
    required int id,
    required String title,
    required String body,
    required DateTime reminderTime,
  }) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final now = DateTime.now();
      final diff = reminderTime.difference(now);

      // If scheduled time is right now or within the last 90 seconds (e.g. user selected current minute):
      if (diff.inSeconds <= 5 && diff.inSeconds >= -90) {
        developer.log(
          'Reminder time is current or within grace window, triggering immediate alarm.',
          name: 'NotificationService',
        );
        return await triggerImmediateAlarm(id: id, title: title, body: body);
      }

      // If more than 90 seconds in the past, skip
      if (diff.inSeconds < -90) {
        developer.log(
          'Reminder time $reminderTime is in the past, skipping schedule.',
          name: 'NotificationService',
        );
        return false;
      }

      final location = tz.local;
      final scheduledDate = tz.TZDateTime(
        location,
        reminderTime.year,
        reminderTime.month,
        reminderTime.day,
        reminderTime.hour,
        reminderTime.minute,
        reminderTime.second,
      );

      final nowInTz = tz.TZDateTime.now(location);
      if (scheduledDate.isBefore(nowInTz)) {
        developer.log(
          'Scheduled date fell slightly behind in tz, triggering immediate alarm.',
          name: 'NotificationService',
        );
        return await triggerImmediateAlarm(id: id, title: title, body: body);
      }

      final androidDetails = _buildAlarmNotificationDetails();
      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
        macOS: darwinDetails,
      );

      try {
        await _notificationsPlugin.zonedSchedule(
          id: id,
          title: title.isNotEmpty ? title : 'Note Reminder',
          body: body.isNotEmpty ? body : 'You have a scheduled note reminder',
          scheduledDate: scheduledDate,
          notificationDetails: notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: id.toString(),
        );
      } catch (e) {
        developer.log(
          'Exact alarm schedule failed, falling back to inexactAllowWhileIdle: $e',
          name: 'NotificationService',
        );
        await _notificationsPlugin.zonedSchedule(
          id: id,
          title: title.isNotEmpty ? title : 'Note Reminder',
          body: body.isNotEmpty ? body : 'You have a scheduled note reminder',
          scheduledDate: scheduledDate,
          notificationDetails: notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: id.toString(),
        );
      }

      developer.log(
        'Scheduled alarm reminder for note $id at $scheduledDate',
        name: 'NotificationService',
      );
      return true;
    } catch (e) {
      developer.log(
        'Error scheduling note reminder: $e',
        name: 'NotificationService',
      );
      return false;
    }
  }

  /// Cancel reminder for a specific note
  Future<void> cancelReminder(int id) async {
    try {
      await _notificationsPlugin.cancel(id: id);
      developer.log('Cancelled reminder for note $id',
          name: 'NotificationService');
    } catch (e) {
      developer.log('Error cancelling reminder: $e',
          name: 'NotificationService');
    }
  }

  /// Cancel all scheduled reminders
  Future<void> cancelAllReminders() async {
    try {
      await _notificationsPlugin.cancelAll();
      developer.log('Cancelled all reminders', name: 'NotificationService');
    } catch (e) {
      developer.log('Error cancelling all reminders: $e',
          name: 'NotificationService');
    }
  }

  /// Display an immediate notification for a nearby note
  Future<bool> showProximityNotification({
    required int id,
    required String noteTitle,
    required double distanceInMeters,
  }) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      const androidDetails = AndroidNotificationDetails(
        'proximity_alerts_channel',
        'Location Proximity Alerts',
        channelDescription:
            'Alerts when approaching a location associated with a note',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      );

      final distanceText = distanceInMeters < 1000
          ? '${distanceInMeters.round()}m away'
          : '${(distanceInMeters / 1000).toStringAsFixed(1)}km away';

      await _notificationsPlugin.show(
        id: id,
        title:
            '📍 Nearby Note: ${noteTitle.isNotEmpty ? noteTitle : "Untitled"}',
        body: 'You are near this note ($distanceText).',
        notificationDetails: notificationDetails,
        payload: 'proximity_$id',
      );
      return true;
    } catch (e) {
      developer.log('Proximity notification error: $e',
          name: 'NotificationService');
      return false;
    }
  }
}
