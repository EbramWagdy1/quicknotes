import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quicknotes/core/localization/l10n_extension.dart';
import 'package:quicknotes/core/theme/app_theme.dart';
import 'package:quicknotes/core/utils/app_colors.dart';
import 'package:quicknotes/core/utils/app_text_style.dart';
import 'package:quicknotes/core/utils/map_launcher.dart';
import 'package:quicknotes/core/utils/note_export_helper.dart';
import 'package:quicknotes/core/utils/snackbar_helper.dart';
import 'package:quicknotes/features/home/model/note_model.dart';
import 'package:quicknotes/features/home/view/widgets/ai_summary_sheet.dart';
import 'package:quicknotes/features/home/view/widgets/voice_note_widget.dart';
import 'package:quicknotes/features/home/view_model/cubit/notes_cubit.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    this.onDelete,
  });

  void _openAiSummary(BuildContext context) {
    String content = note.body.trim();
    if (note.hasSubtasks) {
      final subtasksText = note.subtasks
          .map((s) => '- ${s.title} (${s.isCompleted ? "Done" : "Todo"})')
          .join('\n');
      content = content.isNotEmpty ? '$content\n$subtasksText' : subtasksText;
    }

    AiSummarySheet.show(
      context: context,
      noteTitle: note.title,
      noteContent: content,
      onAppendToNote: (summary) {
        final currentBody = note.body.trim();
        final header = context.isArabic ? '📌 ملخص الذكاء الاصطناعي:' : '📌 AI Summary:';
        final updatedBody = currentBody.isEmpty
            ? '$header\n$summary'
            : '$currentBody\n\n$header\n$summary';
        context.read<NotesCubit>().updateNote(
              note.copyWith(
                body: updatedBody,
                updatedAt: DateTime.now(),
              ),
            );
      },
      onReplaceNote: (summary) {
        context.read<NotesCubit>().updateNote(
              note.copyWith(
                body: summary,
                updatedAt: DateTime.now(),
              ),
            );
      },
    );
  }

  void _showNoteActionsSheet(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkBorder : AppColors.dragHandle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          note.title,
                          style: AppTextStyle.headlineSmall.copyWith(
                            fontWeight: FontWeight.w700,
                            color: context.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: isDark ? AppTheme.darkBorder : AppColors.borderSubtle,
                  height: 16,
                ),
                if (!note.isLocked && (note.body.length >= 10 || note.hasSubtasks))
                  ListTile(
                    leading: const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.skyBlue,
                    ),
                    title: Text(
                      context.l10n.summarizeWithAi,
                      style: AppTextStyle.bodyLarge.copyWith(
                        color: context.textPrimary,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(bottomSheetContext).pop();
                      _openAiSummary(context);
                    },
                  ),
                // Share Note
                ListTile(
                  leading: const Icon(
                    Icons.share_outlined,
                    color: AppColors.skyBlue,
                  ),
                  title: Text(
                    context.l10n.shareNote,
                    style: AppTextStyle.bodyLarge.copyWith(
                      color: context.textPrimary,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    NoteExportHelper.shareNote(note);
                  },
                ),
                ListTile(
                  leading: Icon(
                    note.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: const Color(0xFFF59E0B),
                  ),
                  title: Text(
                    note.isFavorite
                        ? context.l10n.removeFromFavorites
                        : context.l10n.addToFavorites,
                    style: AppTextStyle.bodyLarge.copyWith(
                      color: context.textPrimary,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    context.read<NotesCubit>().toggleFavorite(note);
                  },
                ),
                ListTile(
                  leading: Icon(
                    note.isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                    color: AppColors.primary,
                  ),
                  title: Text(
                    note.isPinned
                        ? context.l10n.unpinNote
                        : context.l10n.pinNote,
                    style: AppTextStyle.bodyLarge.copyWith(
                      color: context.textPrimary,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    context.read<NotesCubit>().togglePin(note);
                  },
                ),
                if (note.hasReminder)
                  ListTile(
                    leading: Icon(
                      Icons.alarm_off_rounded,
                      color: context.textSecondary,
                    ),
                    title: Text(
                      context.l10n.cancelReminder,
                      style: AppTextStyle.bodyLarge.copyWith(
                        color: context.textPrimary,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(bottomSheetContext).pop();
                      context.read<NotesCubit>().updateNote(
                            note.copyWith(clearReminder: true),
                          );
                    },
                  ),
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.destructive,
                  ),
                  title: Text(
                    context.l10n.deleteNote,
                    style: const TextStyle(
                      fontFamily: AppTextStyle.fontFamily,
                      color: AppColors.destructive,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    if (onDelete != null) {
                      onDelete!();
                    } else {
                      final cubit = context.read<NotesCubit>();
                      SnackbarHelper.showDeleteUndoSnackBar(
                        context: context,
                        note: note,
                        cubit: cubit,
                      );
                      cubit.deleteNote(note);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubtasksList(BuildContext context) {
    const maxVisible = 4;
    final visibleTasks = note.subtasks.take(maxVisible).toList();
    final remaining = note.subtasks.length - visibleTasks.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...visibleTasks.map((subtask) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(5),
                    onTap: () {
                      context.read<NotesCubit>().toggleSubtask(
                        note: note,
                        subtaskId: subtask.id,
                        isCompleted: !subtask.isCompleted,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                        right: 8,
                        top: 1,
                        bottom: 1,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: subtask.isCompleted
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                              color: subtask.isCompleted
                                  ? AppColors.primary
                                  : context.borderColor,
                              width: 1.5,
                          ),
                        ),
                        child: subtask.isCompleted
                            ? const Icon(
                                Icons.check_rounded,
                                size: 13,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    subtask.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTextStyle.fontFamily,
                      fontSize: 13,
                      color: subtask.isCompleted
                          ? context.textMuted
                          : context.textPrimary,
                      decoration: subtask.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: context.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        if (remaining > 0)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 26),
            child: Text(
              context.isArabic ? '+ $remaining عناصر أخرى' : '+$remaining more items',
              style: TextStyle(
                fontFamily: AppTextStyle.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: context.textMuted,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final glassBg = isDark
        ? const Color(0xFF1E293B).withValues(alpha: 0.72)
        : Colors.white.withValues(alpha: 0.85);

    final glassBorderColor = note.isPinned
        ? (isDark
            ? AppTheme.darkSkyBlue.withValues(alpha: 0.5)
            : AppColors.primary.withValues(alpha: 0.4))
        : (note.isLocked
            ? (isDark
                ? AppTheme.darkBorder
                : AppColors.primaryFixedDim.withValues(alpha: 0.6))
            : (isDark
                ? const Color(0xFF334155).withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.9)));

    final glassShadow = isDark
        ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
            if (note.isPinned)
              BoxShadow(
                color: AppTheme.darkSkyBlue.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 2),
              ),
          ]
        : [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: (note.isPinned ? AppColors.primary : const Color(0xFF0284C7))
                  .withValues(alpha: note.isPinned ? 0.08 : 0.03),
              blurRadius: 22,
              offset: const Offset(0, 6),
            ),
          ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: glassShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: glassBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: glassBorderColor,
                width: note.isPinned ? 1.5 : 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (note.isLocked) ...[
                      const Padding(
                        padding: EdgeInsets.only(right: 6, top: 2),
                        child: Icon(
                          Icons.lock_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                    Expanded(
                      child: Text(
                        note.title,
                        style: AppTextStyle.headlineSmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Subtle indicator badges (Clean, zero visual noise)
                    if (note.isPinned)
                      const Padding(
                        padding: EdgeInsets.only(left: 6, top: 2),
                        child: Icon(
                          Icons.push_pin_rounded,
                          size: 15,
                          color: AppColors.primary,
                        ),
                      ),
                    if (note.isFavorite)
                      const Padding(
                        padding: EdgeInsets.only(left: 6, top: 2),
                        child: Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                    const SizedBox(width: 4),
                    // Single discreet More Options button
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _showNoteActionsSheet(context),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.more_horiz_rounded,
                          size: 18,
                          color: context.iconColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Note Body, Tasks List, or Locked placeholder
                if (note.isLocked)
                  Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 14,
                        color: context.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        context.l10n.lockedContentPlaceholder,
                        style: AppTextStyle.bodySmall.copyWith(
                          color: context.textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  )
                else if (note.hasSubtasks) ...[
                  _buildSubtasksList(context),
                ] else if (note.body.isNotEmpty) ...[
                  Text(
                    note.body,
                    style: AppTextStyle.bodySmall.copyWith(
                      color: context.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // Voice Note player if present and not locked
                if (note.hasAudio && !note.isLocked) ...[
                  const SizedBox(height: 6),
                  VoiceNotePlayerWidget(
                    audioPath: note.audioPath!,
                    isEditable: false,
                  ),
                ],

                // Tags chips
                if (note.hasTags) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: note.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: context.containerFill,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: context.borderColor,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '#$tag',
                          style: TextStyle(
                            fontFamily: AppTextStyle.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppTheme.darkSkyBlue : AppColors.primary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 14),

                // Footer Metadata row (Timestamp, Location, Subtasks, Lock status)
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Timestamp Chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: context.chipBackground,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: context.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            context.formatDate(note.updatedAt),
                            style: AppTextStyle.labelSmall.copyWith(
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Reminder Chip
                    if (note.hasReminder)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: note.isReminderOverdue
                              ? (isDark ? const Color(0xFF450A0A) : const Color(0xFFFEF2F2))
                              : (isDark ? const Color(0xFF0C4A6E) : AppColors.skyBlueBackground),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: note.isReminderOverdue
                                ? const Color(0xFFFCA5A5)
                                : AppColors.skyBlue.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              note.isReminderOverdue
                                  ? Icons.alarm_off_rounded
                                  : Icons.alarm_rounded,
                              size: 12,
                              color: note.isReminderOverdue
                                  ? AppColors.destructive
                                  : (isDark ? AppTheme.darkSkyBlue : AppColors.skyBlue),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              context.formatReminder(note.reminderAt!),
                              style: AppTextStyle.labelSmall.copyWith(
                                color: note.isReminderOverdue
                                    ? AppColors.destructive
                                    : (isDark ? AppTheme.darkSkyBlue : AppColors.skyBlue),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Subtasks progress chip
                    if (note.hasSubtasks)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              note.completedSubtasksCount ==
                                  note.subtasks.length
                              ? AppColors.tertiaryContainer.withValues(
                                  alpha: isDark ? 0.3 : 0.15,
                                )
                              : context.chipBackground,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.checklist_rounded,
                              size: 12,
                              color:
                                  note.completedSubtasksCount ==
                                      note.subtasks.length
                                  ? AppColors.tertiaryContainer
                                  : context.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${note.completedSubtasksCount}/${note.subtasks.length}',
                              style: AppTextStyle.labelSmall.copyWith(
                                color:
                                    note.completedSubtasksCount ==
                                        note.subtasks.length
                                    ? AppColors.tertiaryContainer
                                    : context.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Location tag
                    if (note.hasLocation)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(6),
                          onTap: () {
                            if (note.latitude != null &&
                                note.longitude != null) {
                              MapLauncher.openMap(
                                note.latitude!,
                                note.longitude!,
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0C4A6E) : AppColors.skyBlueBackground,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  size: 12,
                                  color: isDark ? AppTheme.darkSkyBlue : AppColors.skyBlue,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  context.l10n.viewMap,
                                  style: TextStyle(
                                    fontFamily: AppTextStyle.fontFamily,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppTheme.darkSkyBlue : AppColors.skyBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Locked badge
                    if (note.isLocked)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryFixed.withValues(alpha: isDark ? 0.2 : 0.35),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.lock_rounded,
                              size: 12,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              context.l10n.locked,
                              style: TextStyle(
                                fontFamily: AppTextStyle.fontFamily,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppTheme.darkSkyBlue : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ),
),
);


  }
}
