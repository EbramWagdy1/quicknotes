import 'package:quicknotes/features/home/model/note_model.dart';

abstract final class CalendarHelper {
  const CalendarHelper._();

  static const List<String> monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const List<String> arabicMonthNames = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  static const List<String> weekdayHeaders = [
    'Mo',
    'Tu',
    'We',
    'Th',
    'Fr',
    'Sa',
    'Su',
  ];

  static const List<String> arabicWeekdayHeaders = [
    'إث',
    'ثل',
    'أر',
    'خم',
    'جم',
    'سب',
    'أح',
  ];

  static List<String> getWeekdayHeaders({String? locale}) {
    if (locale == 'ar') return arabicWeekdayHeaders;
    return weekdayHeaders;
  }

  /// Checks if two dates fall on the exact same calendar year, month, and day.
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Calculates number of days in a given year and month.
  static int daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  /// Returns grid dates for the month view starting on Monday (weekday 1).
  /// Fills preceding days from the previous month and succeeding days from the next month.
  static List<DateTime> getDaysForMonth(DateTime monthDate) {
    final firstDayOfMonth = DateTime(monthDate.year, monthDate.month, 1);
    final daysInCurrentMonth = daysInMonth(monthDate.year, monthDate.month);

    // DateTime.weekday: Monday = 1, Sunday = 7
    final firstWeekday = firstDayOfMonth.weekday;
    final leadingDays = firstWeekday - 1;

    final days = <DateTime>[];

    // Leading days from previous month
    for (int i = leadingDays; i > 0; i--) {
      days.add(firstDayOfMonth.subtract(Duration(days: i)));
    }

    // Days of current month
    for (int i = 0; i < daysInCurrentMonth; i++) {
      days.add(DateTime(monthDate.year, monthDate.month, i + 1));
    }

    // Trailing days from next month to complete the row of 7
    final remainingDays = (7 - (days.length % 7)) % 7;
    final lastDayOfMonth = DateTime(monthDate.year, monthDate.month, daysInCurrentMonth);
    for (int i = 1; i <= remainingDays; i++) {
      days.add(lastDayOfMonth.add(Duration(days: i)));
    }

    return days;
  }

  /// Filters notes belonging to a specific calendar day.
  static List<Note> getNotesForDay(
    List<Note> notes,
    DateTime date, {
    bool remindersOnly = false,
  }) {
    return notes.where((note) {
      final matchesReminder =
          note.reminderAt != null && isSameDay(note.reminderAt!, date);
      if (remindersOnly) {
        return matchesReminder;
      }
      final matchesCreated = isSameDay(note.createdAt, date);
      return matchesCreated || matchesReminder;
    }).toList();
  }

  /// Checks if any note has a reminder on the specified day.
  static bool hasReminderOnDay(List<Note> notes, DateTime date) {
    return notes.any(
      (n) => n.reminderAt != null && isSameDay(n.reminderAt!, date),
    );
  }

  /// Checks if any note was created on or has a reminder on the specified day.
  static bool hasNotesOnDay(List<Note> notes, DateTime date) {
    return notes.any((n) {
      final matchesCreated = isSameDay(n.createdAt, date);
      final matchesReminder =
          n.reminderAt != null && isSameDay(n.reminderAt!, date);
      return matchesCreated || matchesReminder;
    });
  }

  /// Formats date to "Month Year" (e.g., "October 2026").
  static String formatMonthYear(DateTime date, {String? locale}) {
    final names = locale == 'ar' ? arabicMonthNames : monthNames;
    final monthName = names[date.month - 1];
    return '$monthName ${date.year}';
  }
}
