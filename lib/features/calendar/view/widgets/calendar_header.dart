import 'package:flutter/material.dart';
import 'package:quicknotes/core/localization/l10n_extension.dart';
import 'package:quicknotes/core/theme/app_theme.dart';
import 'package:quicknotes/core/utils/app_colors.dart';
import 'package:quicknotes/core/utils/app_text_style.dart';
import 'package:quicknotes/core/utils/calendar_helper.dart';

class CalendarHeader extends StatelessWidget {
  final DateTime currentMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onToday;
  final bool remindersOnly;
  final ValueChanged<bool> onToggleRemindersOnly;

  const CalendarHeader({
    super.key,
    required this.currentMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onToday,
    required this.remindersOnly,
    required this.onToggleRemindersOnly,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              // Month Year Title
              Expanded(
                child: Text(
                  CalendarHelper.formatMonthYear(
                    currentMonth,
                    locale: context.languageCode,
                  ),
                  style: TextStyle(
                    fontFamily: AppTextStyle.fontFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ),

              // Today Action Chip
              InkWell(
                onTap: onToday,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0C4A6E) : AppColors.skyBlueBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? AppTheme.darkSkyBlue
                          : AppColors.skyBlue.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.today_rounded,
                        size: 14,
                        color: isDark ? AppTheme.darkSkyBlue : AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        context.l10n.today,
                        style: TextStyle(
                          fontFamily: AppTextStyle.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppTheme.darkSkyBlue : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Previous Month Button
              IconButton(
                icon: Icon(
                  Icons.chevron_left_rounded,
                  color: context.iconColor,
                  size: 26,
                ),
                tooltip: context.isArabic ? 'الشهر السابق' : 'Previous month',
                onPressed: onPreviousMonth,
              ),

              // Next Month Button
              IconButton(
                icon: Icon(
                  Icons.chevron_right_rounded,
                  color: context.iconColor,
                  size: 26,
                ),
                tooltip: context.isArabic ? 'الشهر التالي' : 'Next month',
                onPressed: onNextMonth,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Filters / Legend Row
          Row(
            children: [
              FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.alarm_rounded,
                      size: 14,
                      color: remindersOnly ? Colors.white : const Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      context.l10n.remindersOnly,
                      style: TextStyle(
                        fontFamily: AppTextStyle.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: remindersOnly ? Colors.white : context.textSecondary,
                      ),
                    ),
                  ],
                ),
                selected: remindersOnly,
                onSelected: onToggleRemindersOnly,
                backgroundColor: context.surfaceColor,
                selectedColor: isDark ? AppTheme.darkSkyBlue : AppColors.skyBlue,
                checkmarkColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: remindersOnly
                        ? (isDark ? AppTheme.darkSkyBlue : AppColors.skyBlue)
                        : context.borderColor,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
              const Spacer(),
              // Indicators legend
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkSkyBlue : AppColors.skyBlue,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    context.isArabic ? 'ملاحظات' : 'Notes',
                    style: TextStyle(
                      fontFamily: AppTextStyle.fontFamily,
                      fontSize: 11,
                      color: context.textMuted,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF59E0B),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    context.l10n.reminders,
                    style: TextStyle(
                      fontFamily: AppTextStyle.fontFamily,
                      fontSize: 11,
                      color: context.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
