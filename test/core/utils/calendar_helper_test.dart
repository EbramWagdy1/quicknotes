import 'package:flutter_test/flutter_test.dart';
import 'package:quicknotes/core/utils/calendar_helper.dart';
import 'package:quicknotes/features/home/model/note_model.dart';

void main() {
  group('CalendarHelper Tests', () {
    test('isSameDay correctly identifies same or different calendar days', () {
      final d1 = DateTime(2026, 10, 6, 10, 30);
      final d2 = DateTime(2026, 10, 6, 23, 59);
      final d3 = DateTime(2026, 10, 7, 10, 30);

      expect(CalendarHelper.isSameDay(d1, d2), isTrue);
      expect(CalendarHelper.isSameDay(d1, d3), isFalse);
    });

    test('daysInMonth returns accurate number of days for leap and non-leap years', () {
      expect(CalendarHelper.daysInMonth(2026, 2), equals(28));
      expect(CalendarHelper.daysInMonth(2024, 2), equals(29));
      expect(CalendarHelper.daysInMonth(2026, 10), equals(31));
      expect(CalendarHelper.daysInMonth(2026, 4), equals(30));
    });

    test('getDaysForMonth returns exactly 35 or 42 grid cells starting on Monday', () {
      final date = DateTime(2026, 10, 1);
      final days = CalendarHelper.getDaysForMonth(date);

      // Must be a multiple of 7
      expect(days.length % 7, equals(0));
      expect(days.length, inInclusiveRange(28, 42));

      // The first day in the grid must be Monday (weekday == 1)
      expect(days.first.weekday, equals(DateTime.monday));

      // Contains October 1st and October 31st
      expect(days.any((d) => d.year == 2026 && d.month == 10 && d.day == 1), isTrue);
      expect(days.any((d) => d.year == 2026 && d.month == 10 && d.day == 31), isTrue);
    });

    test('getNotesForDay filters notes by created date and reminder date', () {
      final targetDate = DateTime(2026, 10, 6);
      final note1 = Note(
        id: 1,
        title: 'Created Today',
        body: 'Content',
        createdAt: DateTime(2026, 10, 6, 9, 0),
        updatedAt: DateTime(2026, 10, 6, 9, 0),
      );
      final note2 = Note(
        id: 2,
        title: 'Created Earlier with Reminder Today',
        body: 'Content',
        createdAt: DateTime(2026, 10, 1, 9, 0),
        updatedAt: DateTime(2026, 10, 1, 9, 0),
        reminderAt: DateTime(2026, 10, 6, 15, 0),
      );
      final note3 = Note(
        id: 3,
        title: 'Tomorrow Note',
        body: 'Content',
        createdAt: DateTime(2026, 10, 7, 9, 0),
        updatedAt: DateTime(2026, 10, 7, 9, 0),
      );

      final allNotes = [note1, note2, note3];

      final dayNotes = CalendarHelper.getNotesForDay(allNotes, targetDate);
      expect(dayNotes.length, equals(2));
      expect(dayNotes.map((n) => n.id), containsAll([1, 2]));

      final reminderNotes = CalendarHelper.getNotesForDay(
        allNotes,
        targetDate,
        remindersOnly: true,
      );
      expect(reminderNotes.length, equals(1));
      expect(reminderNotes.first.id, equals(2));
    });

    test('hasReminderOnDay and hasNotesOnDay detect day indicators accurately', () {
      final date = DateTime(2026, 10, 6);
      final otherDate = DateTime(2026, 10, 20);

      final note = Note(
        id: 1,
        title: 'Meeting',
        body: 'Discuss roadmap',
        createdAt: DateTime(2026, 10, 6, 8, 0),
        updatedAt: DateTime(2026, 10, 6, 8, 0),
        reminderAt: DateTime(2026, 10, 6, 14, 0),
      );

      expect(CalendarHelper.hasNotesOnDay([note], date), isTrue);
      expect(CalendarHelper.hasReminderOnDay([note], date), isTrue);

      expect(CalendarHelper.hasNotesOnDay([note], otherDate), isFalse);
      expect(CalendarHelper.hasReminderOnDay([note], otherDate), isFalse);
    });

    test('formatMonthYear formats dates correctly', () {
      expect(CalendarHelper.formatMonthYear(DateTime(2026, 10, 1)), equals('October 2026'));
      expect(CalendarHelper.formatMonthYear(DateTime(2027, 1, 15)), equals('January 2027'));
    });
  });
}
