import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quicknotes/core/localization/l10n_extension.dart';
import 'package:quicknotes/core/routing/app_routes.dart';
import 'package:quicknotes/core/theme/app_theme.dart';
import 'package:quicknotes/core/utils/app_colors.dart';
import 'package:quicknotes/core/utils/app_text_style.dart';
import 'package:quicknotes/core/utils/calendar_helper.dart';
import 'package:quicknotes/features/home/model/note_model.dart';
import 'package:quicknotes/features/home/view/widgets/note_card.dart';

class CalendarDayNotes extends StatelessWidget {
  final DateTime selectedDay;
  final List<Note> notes;
  final bool remindersOnly;
  final VoidCallback onAddNote;

  const CalendarDayNotes({
    super.key,
    required this.selectedDay,
    required this.notes,
    required this.remindersOnly,
    required this.onAddNote,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isToday = CalendarHelper.isSameDay(selectedDay, now);
    final isDark = context.isDarkMode;

    final isAr = context.isArabic;
    final weekdayName = _getWeekdayName(selectedDay.weekday, isAr: isAr);
    final monthName = isAr
        ? CalendarHelper.arabicMonthNames[selectedDay.month - 1]
        : CalendarHelper.monthNames[selectedDay.month - 1];
    final dateTitle = isToday
        ? (isAr ? 'اليوم، ${selectedDay.day} $monthName' : 'Today, $monthName ${selectedDay.day}')
        : (isAr ? '$weekdayName، ${selectedDay.day} $monthName' : '$weekdayName, $monthName ${selectedDay.day}');

    final notesCountText = isAr
        ? '${notes.length} ${notes.length == 1 ? 'ملاحظة' : 'ملاحظات'}'
        : '${notes.length} ${notes.length == 1 ? 'note' : 'notes'}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Text(
                dateTitle,
                style: TextStyle(
                  fontFamily: AppTextStyle.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0C4A6E) : AppColors.skyBlueBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  notesCountText,
                  style: TextStyle(
                    fontFamily: AppTextStyle.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.darkSkyBlue : AppColors.primary,
                  ),
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onAddNote,
                icon: const Icon(Icons.add_rounded, size: 16),
                label: Text(isAr ? 'إضافة ملاحظة' : 'Add Note'),
                style: TextButton.styleFrom(
                  foregroundColor: isDark ? AppTheme.darkSkyBlue : AppColors.primary,
                  textStyle: const TextStyle(
                    fontFamily: AppTextStyle.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Notes List or Empty State
          if (notes.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.borderColor, width: 1),
                boxShadow: isDark ? const [] : AppColors.tier1Shadow,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0C4A6E) : AppColors.skyBlueBackground,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      remindersOnly
                          ? Icons.notifications_none_rounded
                          : Icons.event_note_outlined,
                      color: isDark ? AppTheme.darkSkyBlue : AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    remindersOnly
                        ? (isAr ? 'لا توجد تذكيرات مجدولة لهذا اليوم' : 'No reminders scheduled for this day')
                        : (isAr ? 'لا توجد ملاحظات لهذا التاريخ' : 'No notes for this date'),
                    style: TextStyle(
                      fontFamily: AppTextStyle.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    remindersOnly
                        ? (isAr ? 'يمكنك جدولة تذكير من أي ملاحظة' : 'Schedule a reminder from any note')
                        : (isAr ? 'اضغط على "إضافة ملاحظة" لإنشاء ملاحظة لهذا اليوم' : 'Tap "Add Note" to create one for this day'),
                    style: TextStyle(
                      fontFamily: AppTextStyle.fontFamily,
                      fontSize: 12,
                      color: context.textMuted,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: notes.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final note = notes[index];
                return NoteCard(
                  key: ValueKey('calendar_note_${note.id}'),
                  note: note,
                  onTap: () {
                    context.push(AppRoutes.editNote, extra: note);
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  String _getWeekdayName(int weekday, {bool isAr = false}) {
    if (isAr) {
      switch (weekday) {
        case DateTime.monday:
          return 'الإثنين';
        case DateTime.tuesday:
          return 'الثلاثاء';
        case DateTime.wednesday:
          return 'الأربعاء';
        case DateTime.thursday:
          return 'الخميس';
        case DateTime.friday:
          return 'الجمعة';
        case DateTime.saturday:
          return 'السبت';
        case DateTime.sunday:
          return 'الأحد';
        default:
          return '';
      }
    }
    switch (weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return '';
    }
  }
}
