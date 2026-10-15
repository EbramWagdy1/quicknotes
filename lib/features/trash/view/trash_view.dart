import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quicknotes/core/theme/app_theme.dart';
import 'package:quicknotes/core/utils/app_colors.dart';
import 'package:quicknotes/core/utils/app_text_style.dart';
import 'package:quicknotes/core/localization/l10n_extension.dart';
import 'package:quicknotes/features/home/model/note_model.dart';
import 'package:quicknotes/features/home/view_model/cubit/notes_cubit.dart';

class TrashView extends StatelessWidget {
  const TrashView({super.key});

  Future<void> _confirmEmptyTrash(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: context.borderColor),
        ),
        title: Text(
          context.isArabic ? 'إفراغ سلة المهملات؟' : 'Empty Trash?',
          style: AppTextStyle.headlineSmall.copyWith(color: context.textPrimary),
        ),
        content: Text(
          context.isArabic
              ? 'سيتم حذف جميع الملاحظات في سلة المهملات نهائياً. لا يمكن التراجع عن هذا الإجراء.'
              : 'All notes in Trash will be permanently deleted. This action cannot be undone.',
          style: AppTextStyle.bodyMedium.copyWith(color: context.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              context.l10n.cancel,
              style: TextStyle(color: context.textSecondary),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.destructive),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(context.l10n.deleteForever),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<NotesCubit>().emptyTrash();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.slate900,
            content: Text(
              context.isArabic
                  ? 'تم إفراغ المهملات نهائياً'
                  : 'Trash emptied permanently',
            ),
          ),
        );
      }
    }
  }

  Future<void> _confirmDeletePermanently(BuildContext context, Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: context.borderColor),
        ),
        title: Text(
          context.isArabic ? 'حذف نهائي؟' : 'Delete Forever?',
          style: AppTextStyle.headlineSmall.copyWith(color: context.textPrimary),
        ),
        content: Text(
          context.isArabic
              ? 'هل أنت متأكد من رغبتك في حذف "${note.title.isNotEmpty ? note.title : 'هذه الملاحظة'}" نهائياً؟'
              : 'Are you sure you want to permanently delete "${note.title.isNotEmpty ? note.title : 'this note'}"?',
          style: AppTextStyle.bodyMedium.copyWith(color: context.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              context.l10n.cancel,
              style: TextStyle(color: context.textSecondary),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.destructive),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<NotesCubit>().permanentlyDeleteNote(note);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.canvasColor,
      appBar: AppBar(
        backgroundColor: context.canvasColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: context.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          context.l10n.trash,
          style: AppTextStyle.headlineLarge.copyWith(color: context.textPrimary),
        ),
        actions: [
          BlocBuilder<NotesCubit, NotesState>(
            builder: (context, state) {
              final trashNotes =
                  state is NotesLoaded ? state.trashNotes : <Note>[];
              if (trashNotes.isEmpty) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: TextButton.icon(
                  onPressed: () => _confirmEmptyTrash(context),
                  icon: const Icon(
                    Icons.delete_forever_rounded,
                    color: AppColors.destructive,
                    size: 18,
                  ),
                  label: Text(
                    context.l10n.emptyTrash,
                    style: const TextStyle(
                      fontFamily: AppTextStyle.fontFamily,
                      color: AppColors.destructive,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<NotesCubit, NotesState>(
        builder: (context, state) {
          if (state is! NotesLoaded) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.skyBlue),
            );
          }

          final trashNotes = state.trashNotes;

          if (trashNotes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: context.containerFill,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: context.borderColor,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.delete_outline_rounded,
                          size: 38,
                          color: context.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      context.l10n.trashIsEmpty,
                      style: AppTextStyle.headlineMedium.copyWith(
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.trashEmptySubtitle,
                      textAlign: TextAlign.center,
                      style: AppTextStyle.bodyMedium.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            itemCount: trashNotes.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final note = trashNotes[index];
              return _TrashNoteCard(
                note: note,
                onRestore: () async {
                  await context.read<NotesCubit>().restoreNote(note);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppColors.slate900,
                        content: Text(
                          context.isArabic
                              ? 'تم استعادة ملاحظة "${note.title.isNotEmpty ? note.title : 'بدون عنوان'}"'
                              : 'Note "${note.title.isNotEmpty ? note.title : 'Note'}" restored',
                        ),
                      ),
                    );
                  }
                },
                onDeletePermanently: () =>
                    _confirmDeletePermanently(context, note),
              );
            },
          );
        },
      ),
    );
  }
}

class _TrashNoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onRestore;
  final VoidCallback onDeletePermanently;

  const _TrashNoteCard({
    required this.note,
    required this.onRestore,
    required this.onDeletePermanently,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor, width: 1),
        boxShadow: isDark ? const [] : AppColors.tier1Shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  note.title.isNotEmpty ? note.title : 'Untitled Note',
                  style: AppTextStyle.headlineSmall.copyWith(
                    color: context.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                context.formatDate(note.updatedAt),
                style: AppTextStyle.labelSmall.copyWith(
                  color: context.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (note.hasSubtasks)
            Text(
              context.isArabic
                  ? '${note.subtasks.length} عناصر في القائمة'
                  : '${note.subtasks.length} checklist items',
              style: AppTextStyle.bodySmall.copyWith(
                color: context.textSecondary,
              ),
            )
          else if (note.body.isNotEmpty)
            Text(
              note.body,
              style: AppTextStyle.bodySmall.copyWith(
                color: context.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 14),
          Divider(height: 1, color: context.borderColor),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.destructive,
                  side: const BorderSide(color: AppColors.destructive, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                onPressed: onDeletePermanently,
                icon: const Icon(Icons.delete_forever_rounded, size: 16),
                label: Text(context.isArabic ? 'حذف نهائي' : 'Delete'),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: isDark ? AppTheme.darkSkyBlue : AppColors.primary,
                  foregroundColor: isDark ? AppTheme.darkCanvas : AppColors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                onPressed: onRestore,
                icon: const Icon(Icons.restore_from_trash_rounded, size: 16),
                label: Text(context.l10n.restore),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
