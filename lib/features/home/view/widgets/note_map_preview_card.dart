import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quicknotes/core/localization/l10n_extension.dart';
import 'package:quicknotes/core/routing/app_routes.dart';
import 'package:quicknotes/core/theme/app_theme.dart';
import 'package:quicknotes/core/utils/app_colors.dart';
import 'package:quicknotes/core/utils/app_text_style.dart';
import 'package:quicknotes/core/utils/map_launcher.dart';
import 'package:quicknotes/features/home/model/note_model.dart';

class NoteMapPreviewCard extends StatelessWidget {
  final Note note;
  final VoidCallback onClose;
  final VoidCallback? onCenterOnNote;

  const NoteMapPreviewCard({
    super.key,
    required this.note,
    required this.onClose,
    this.onCenterOnNote,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark ? const [] : AppColors.tier3Shadow,
        border: Border.all(color: context.borderColor, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Title + Badges + Close
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        if (note.isPinned) ...[
                          const Icon(
                            Icons.push_pin_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                        ],
                        if (note.isFavorite) ...[
                          const Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 4),
                        ],
                        if (note.hasReminder) ...[
                          Icon(
                            note.isReminderOverdue
                                ? Icons.alarm_off_rounded
                                : Icons.alarm_rounded,
                            size: 16,
                            color: note.isReminderOverdue
                                ? AppColors.destructive
                                : (isDark ? AppTheme.darkSkyBlue : AppColors.skyBlue),
                          ),
                          const SizedBox(width: 4),
                        ],
                        Expanded(
                          child: Text(
                            note.title.isEmpty
                                ? (context.isArabic ? 'ملاحظة بدون عنوان' : 'Untitled Note')
                                : note.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: AppTextStyle.fontFamily,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: context.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    color: context.textMuted,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 16,
                    onPressed: onClose,
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // Body preview or subtasks progress
              if (note.hasSubtasks) ...[
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: note.subtasksProgress,
                          backgroundColor: context.containerFill,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark ? AppTheme.darkSkyBlue : AppColors.primary,
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      context.isArabic
                          ? '${note.completedSubtasksCount} من ${note.subtasks.length} مكتملة'
                          : '${note.completedSubtasksCount}/${note.subtasks.length} done',
                      style: TextStyle(
                        fontFamily: AppTextStyle.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ] else if (note.body.isNotEmpty) ...[
                Text(
                  note.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTextStyle.fontFamily,
                    fontSize: 13,
                    color: context.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],

              // Tags row if available
              if (note.hasTags) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: note.tags.take(3).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0C4A6E) : AppColors.skyBlueBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#$tag',
                        style: TextStyle(
                          fontFamily: AppTextStyle.fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppTheme.darkSkyBlue : AppColors.primary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 12),

              // Action buttons row
              Row(
                children: [
                  // Open & Edit note
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppTheme.darkSkyBlue : AppColors.primary,
                        foregroundColor: isDark ? AppTheme.darkCanvas : Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.edit_note_rounded, size: 18),
                      label: Text(
                        context.isArabic ? 'فتح الملاحظة' : 'Open Note',
                        style: const TextStyle(
                          fontFamily: AppTextStyle.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () {
                        context.push(AppRoutes.editNote, extra: note);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Open External Google Maps / Navigation
                  if (note.hasLocation)
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.textPrimary,
                        side: BorderSide(color: context.borderColor),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.directions_rounded, size: 18),
                      label: Text(
                        context.isArabic ? 'الاتجاهات' : 'Directions',
                        style: const TextStyle(
                          fontFamily: AppTextStyle.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () {
                        MapLauncher.openMap(note.latitude!, note.longitude!);
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
