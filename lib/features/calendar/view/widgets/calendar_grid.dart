import 'package:flutter/material.dart';
import 'package:quicknotes/core/localization/l10n_extension.dart';
import 'package:quicknotes/core/theme/app_theme.dart';
import 'package:quicknotes/core/utils/app_colors.dart';
import 'package:quicknotes/core/utils/app_text_style.dart';
import 'package:quicknotes/core/utils/calendar_helper.dart';
import 'package:quicknotes/features/home/model/note_model.dart';

class CalendarGrid extends StatelessWidget {
  final DateTime currentMonth;
  final DateTime selectedDay;
  final List<Note> notes;
  final ValueChanged<DateTime> onSelectDay;

  const CalendarGrid({
    super.key,
    required this.currentMonth,
    required this.selectedDay,
    required this.notes,
    required this.onSelectDay,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = CalendarHelper.getDaysForMonth(currentMonth);
    final isDark = context.isDarkMode;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor, width: 1),
        boxShadow: isDark
            ? const []
            : const [
                BoxShadow(
                  color: Color(0x050F172A),
                  offset: Offset(0, 2),
                  blurRadius: 6,
                ),
              ],
      ),
      child: Column(
        children: [
          // Weekday Labels Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: CalendarHelper.getWeekdayHeaders(
              locale: context.languageCode,
            ).map((header) {
              return Expanded(
                child: Center(
                  child: Text(
                    header,
                    style: TextStyle(
                      fontFamily: AppTextStyle.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: context.textMuted,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),

          // Days Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: days.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              final day = days[index];
              final isCurrentMonth = day.month == currentMonth.month;
              final isSelected = CalendarHelper.isSameDay(day, selectedDay);
              final isToday = CalendarHelper.isSameDay(day, today);
              final hasNote = CalendarHelper.hasNotesOnDay(notes, day);
              final hasReminder = CalendarHelper.hasReminderOnDay(notes, day);

              Color textColor;
              if (isSelected) {
                textColor = isDark ? AppTheme.darkCanvas : Colors.white;
              } else if (!isCurrentMonth) {
                textColor = context.textMuted.withValues(alpha: 0.4);
              } else if (isToday) {
                textColor = isDark ? AppTheme.darkSkyBlue : AppColors.primary;
              } else {
                textColor = context.textPrimary;
              }

              return InkWell(
                onTap: () => onSelectDay(day),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? AppTheme.darkSkyBlue : AppColors.skyBlue)
                        : (isToday
                            ? (isDark ? const Color(0xFF0C4A6E) : AppColors.skyBlueBackground)
                            : Colors.transparent),
                    borderRadius: BorderRadius.circular(10),
                    border: isToday && !isSelected
                        ? Border.all(
                            color: isDark ? AppTheme.darkSkyBlue : AppColors.skyBlue,
                            width: 1.5,
                          )
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${day.day}',
                        style: TextStyle(
                          fontFamily: AppTextStyle.fontFamily,
                          fontSize: 13,
                          fontWeight: (isSelected || isToday)
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 2),

                      // Indicators (Notes & Reminders)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (hasNote)
                            Container(
                              width: 4,
                              height: 4,
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isDark ? AppTheme.darkCanvas : Colors.white)
                                    : (isDark ? AppTheme.darkSkyBlue : AppColors.skyBlue),
                                shape: BoxShape.circle,
                              ),
                            ),
                          if (hasReminder)
                            Container(
                              width: 4,
                              height: 4,
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFFDE68A)
                                    : const Color(0xFFF59E0B),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
