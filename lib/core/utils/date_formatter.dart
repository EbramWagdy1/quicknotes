abstract final class DateFormatter {
  const DateFormatter._();

  static const List<String> _enMonths = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static const List<String> _arMonths = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  static String format(DateTime date, {String? locale}) {
    final isAr = locale != null && locale.startsWith('ar');
    final now = DateTime.now();
    final difference = now.difference(date);

    final hour = date.hour > 12
        ? date.hour - 12
        : (date.hour == 0 ? 12 : date.hour);
    final period = date.hour >= 12 ? (isAr ? 'م' : 'PM') : (isAr ? 'ص' : 'AM');
    final minute = date.minute.toString().padLeft(2, '0');
    final timeStr = '$hour:$minute $period';

    if (difference.inDays == 0 && now.day == date.day) {
      return isAr ? 'اليوم، $timeStr' : 'Today, $timeStr';
    } else if (difference.inDays == 1 ||
        (difference.inDays == 0 && now.day != date.day)) {
      return isAr ? 'أمس، $timeStr' : 'Yesterday, $timeStr';
    } else {
      final month = isAr ? _arMonths[date.month - 1] : _enMonths[date.month - 1];
      return isAr
          ? '${date.day} $month ${date.year}'
          : '$month ${date.day}, ${date.year}';
    }
  }

  static String formatReminder(DateTime reminderDate, {String? locale}) {
    final isAr = locale != null && locale.startsWith('ar');
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final reminderDay = DateTime(
      reminderDate.year,
      reminderDate.month,
      reminderDate.day,
    );

    final hour = reminderDate.hour > 12
        ? reminderDate.hour - 12
        : (reminderDate.hour == 0 ? 12 : reminderDate.hour);
    final period = reminderDate.hour >= 12 ? (isAr ? 'م' : 'PM') : (isAr ? 'ص' : 'AM');
    final minute = reminderDate.minute.toString().padLeft(2, '0');
    final timeStr = '$hour:$minute $period';

    final daysDiff = reminderDay.difference(today).inDays;

    if (daysDiff == 0) {
      return isAr ? 'اليوم، $timeStr' : 'Today, $timeStr';
    } else if (daysDiff == 1) {
      return isAr ? 'غداً، $timeStr' : 'Tomorrow, $timeStr';
    } else if (daysDiff == -1) {
      return isAr ? 'أمس، $timeStr' : 'Yesterday, $timeStr';
    } else {
      final month = isAr ? _arMonths[reminderDate.month - 1] : _enMonths[reminderDate.month - 1];
      return isAr
          ? '${reminderDate.day} $month، $timeStr'
          : '$month ${reminderDate.day}, $timeStr';
    }
  }
}
