import 'package:flutter/material.dart';
import 'package:quicknotes/core/localization/l10n_extension.dart';
import 'package:quicknotes/core/theme/app_theme.dart';
import 'package:quicknotes/core/utils/app_colors.dart';
import 'package:quicknotes/core/utils/app_text_style.dart';
import 'package:quicknotes/core/utils/note_stats_helper.dart';
import 'package:quicknotes/features/home/model/note_model.dart';

class ProductivityStatsSheet extends StatelessWidget {
  final List<Note> activeNotes;
  final List<Note> trashNotes;

  const ProductivityStatsSheet({
    super.key,
    required this.activeNotes,
    required this.trashNotes,
  });

  static Future<void> show(
    BuildContext context, {
    required List<Note> activeNotes,
    required List<Note> trashNotes,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ProductivityStatsSheet(
        activeNotes: activeNotes,
        trashNotes: trashNotes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = NoteStatsHelper.calculate(
      activeNotes: activeNotes,
      trashNotes: trashNotes,
    );
    final isDark = context.isDarkMode;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkBorder : AppColors.dragHandle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0C4A6E)
                        : AppColors.skyBlueBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.insights_rounded,
                    color: AppColors.skyBlue,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.productivityInsights,
                        style: AppTextStyle.headlineSmall.copyWith(
                          color: context.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        context.l10n.productivitySubtitle,
                        style: AppTextStyle.bodySmall.copyWith(
                          color: context.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: context.textSecondary,
                    size: 20,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Task Completion Banner Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : AppColors.cardWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.borderColor, width: 1),
                boxShadow: isDark ? const [] : AppColors.tier1Shadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.tasksCompletion,
                        style: AppTextStyle.bodyMedium.copyWith(
                          color: context.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${stats.taskCompletionPercentage.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontFamily: AppTextStyle.fontFamily,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.skyBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: stats.totalSubtasks > 0
                          ? (stats.completedSubtasks / stats.totalSubtasks)
                          : 0.0,
                      minHeight: 8,
                      backgroundColor: context.containerFill,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.skyBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    stats.totalSubtasks > 0
                        ? (context.isArabic
                            ? 'تم إنجاز ${stats.completedSubtasks} من أصل ${stats.totalSubtasks} مهمة فرعية'
                            : '${stats.completedSubtasks} of ${stats.totalSubtasks} checklist tasks completed')
                        : context.l10n.noChecklistTasksYet,
                    style: TextStyle(
                      fontFamily: AppTextStyle.fontFamily,
                      fontSize: 12,
                      color: context.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 2x2 Metric Grid
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    context: context,
                    icon: Icons.description_outlined,
                    iconColor: AppColors.skyBlue,
                    label: context.l10n.activeNotes,
                    value: '${stats.totalActiveNotes}',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricTile(
                    context: context,
                    icon: Icons.alarm_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    label: context.l10n.reminders,
                    value: '${stats.notesWithRemindersCount}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    context: context,
                    icon: Icons.star_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    label: context.l10n.favoritesAndPinned,
                    value: '${stats.favoriteCount} / ${stats.pinnedCount}',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricTile(
                    context: context,
                    icon: Icons.delete_outline_rounded,
                    iconColor: AppColors.destructive,
                    label: context.l10n.inTrash,
                    value: '${stats.trashNotesCount}',
                  ),
                ),
              ],
            ),

            // Tag Distribution
            if (stats.tagDistribution.isNotEmpty) ...[
              const SizedBox(height: 18),
              Text(
                context.l10n.topTags,
                style: AppTextStyle.bodyMedium.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: stats.tagDistribution.entries.take(6).map((entry) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: context.containerFill,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: context.borderColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '#${entry.key}',
                          style: TextStyle(
                            fontFamily: AppTextStyle.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppTheme.darkSkyBlue : AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: context.chipBackground,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${entry.value}',
                            style: TextStyle(
                              fontFamily: AppTextStyle.fontFamily,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: context.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    final isDark = context.isDarkMode;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppColors.cardWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppTextStyle.fontFamily,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTextStyle.fontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: context.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
