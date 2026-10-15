import 'package:flutter_test/flutter_test.dart';
import 'package:quicknotes/core/services/notification_service.dart';
import 'package:quicknotes/core/utils/date_formatter.dart';

void main() {
  group('NotificationService Unit Tests', () {
    test('NotificationService initial state is not initialized', () {
      final service = NotificationService();
      expect(service.isInitialized, false);
    });

    test('scheduleNoteReminder returns false if reminder time is in the past', () async {
      final service = NotificationService();
      final pastDate = DateTime.now().subtract(const Duration(minutes: 10));

      final scheduled = await service.scheduleNoteReminder(
        id: 1,
        title: 'Past reminder',
        body: 'Past body',
        reminderTime: pastDate,
      );

      expect(scheduled, false);
    });

    test('cancelReminder handles gracefully without throwing', () async {
      final service = NotificationService();
      await expectLater(service.cancelReminder(1), completes);
    });

    test('cancelAllReminders handles gracefully without throwing', () async {
      final service = NotificationService();
      await expectLater(service.cancelAllReminders(), completes);
    });

    test('showProximityNotification handles gracefully without throwing when uninitialized', () async {
      final service = NotificationService();
      await expectLater(
        service.showProximityNotification(
          id: 1,
          noteTitle: 'Nearby Grocery Note',
          distanceInMeters: 250,
        ),
        completes,
      );
    });

    test('Alarm channel constants are configured correctly', () {
      expect(NotificationService.alarmChannelId, 'note_reminders_alarm_channel_v2');
      expect(NotificationService.alarmChannelName, 'Note Reminders & Alarms');
      expect(NotificationService.alarmChannelDesc, contains('Alarm notifications'));
    });

    test('triggerImmediateAlarm completes gracefully when uninitialized', () async {
      final service = NotificationService();
      await expectLater(
        service.triggerImmediateAlarm(
          id: 1,
          title: 'Immediate Alarm',
          body: 'Alarm body',
        ),
        completes,
      );
    });

    test('requestPermissions completes gracefully without error', () async {
      final service = NotificationService();
      await expectLater(service.requestPermissions(), completes);
    });
  });

  group('DateFormatter formatReminder Tests', () {
    test('formats today correctly', () {
      final now = DateTime.now();
      final todayDate = DateTime(now.year, now.month, now.day, 14, 30);
      final formatted = DateFormatter.formatReminder(todayDate);
      expect(formatted, contains('Today, 2:30 PM'));
    });

    test('formats tomorrow correctly', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final tomorrowDate = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9, 15);
      final formatted = DateFormatter.formatReminder(tomorrowDate);
      expect(formatted, contains('Tomorrow, 9:15 AM'));
    });

    test('formats future date with month and day', () {
      final futureDate = DateTime(2027, 8, 20, 10, 0);
      final formatted = DateFormatter.formatReminder(futureDate);
      expect(formatted, contains('Aug 20, 10:00 AM'));
    });
  });
}
