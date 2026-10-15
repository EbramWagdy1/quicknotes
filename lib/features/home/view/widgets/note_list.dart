import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quicknotes/core/theme/app_theme.dart';
import 'package:quicknotes/core/di/injection.dart';
import 'package:quicknotes/core/localization/l10n_extension.dart';
import 'package:quicknotes/core/routing/app_routes.dart';
import 'package:quicknotes/core/services/biometric_service.dart';
import 'package:quicknotes/core/utils/app_colors.dart';
import 'package:quicknotes/core/utils/app_text_style.dart';
import 'package:quicknotes/core/utils/snackbar_helper.dart';
import 'package:quicknotes/features/home/model/note_model.dart';
import 'package:quicknotes/features/home/view/widgets/note_card.dart';
import 'package:quicknotes/features/home/view_model/cubit/notes_cubit.dart';

class NoteList extends StatelessWidget {
  final List<Note> notes;

  const NoteList({super.key, required this.notes});

  Future<void> _handleTap(BuildContext context, Note note) async {
    if (note.isLocked) {
      final biometricService = sl.isRegistered<BiometricService>()
          ? sl<BiometricService>()
          : BiometricService();

      final authenticated = await biometricService.authenticate(
        localizedReason: context.isArabic
            ? 'يلزم التحقق لفتح "${note.title.isNotEmpty ? note.title : 'الملاحظة المقفلة'}"'
            : 'Authenticate to view "${note.title.isNotEmpty ? note.title : 'Locked note'}"',
      );

      if (!authenticated) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.slate900,
                duration: const Duration(seconds: 2),
                content: Text(context.l10n.authRequiredLocked),
              ),
            );
        }
        return;
      }
    }

    if (context.mounted) {
      context.push(AppRoutes.editNote, extra: note);
    }
  }

  Future<void> _handleDelete(BuildContext context, Note note) async {
    final cubit = context.read<NotesCubit>();

    if (note.isLocked) {
      final biometricService = sl.isRegistered<BiometricService>()
          ? sl<BiometricService>()
          : BiometricService();

      final authenticated = await biometricService.authenticate(
        localizedReason: context.isArabic
            ? 'يلزم التحقق لحذف الملاحظة المقفلة'
            : 'Authenticate to delete locked note',
      );

      if (!authenticated) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.slate900,
                duration: const Duration(seconds: 2),
                content: Text(context.l10n.authRequiredDeleteLocked),
              ),
            );
        }
        return;
      }
    }

    // Show 10-second Undo SnackBar immediately
    SnackbarHelper.showDeleteUndoSnackBar(
      note: note,
      cubit: cubit,
    );

    await cubit.deleteNote(note);
  }

  Widget _buildDismissibleCard(BuildContext context, Note note) {
    return Dismissible(
      key: ValueKey(note.id ?? note.createdAt.toIso8601String()),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        if (note.isLocked) {
          final biometricService = sl.isRegistered<BiometricService>()
              ? sl<BiometricService>()
              : BiometricService();
          return await biometricService.authenticate(
            localizedReason: context.isArabic
                ? 'يلزم التحقق لحذف الملاحظة المقفلة'
                : 'Authenticate to delete locked note',
          );
        }
        return true;
      },
      onDismissed: (_) {
        _handleDelete(context, note);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.destructive,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Icon(
              Icons.delete_outline_rounded,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              context.l10n.delete,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      child: NoteCard(
        note: note,
        onTap: () => _handleTap(context, note),
        onDelete: () {
          _handleDelete(context, note);
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: context.accentColor),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              fontFamily: AppTextStyle.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: context.textSecondary,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pinned = notes.where((n) => n.isPinned).toList();
    final other = notes.where((n) => !n.isPinned).toList();
    final hasPinned = pinned.isNotEmpty;

    return RefreshIndicator(
      color: context.accentColor,
      backgroundColor: context.surfaceColor,
      onRefresh: () {
        return context.read<NotesCubit>().loadNotes();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          if (hasPinned) ...[
            _buildSectionHeader(context, context.l10n.pinnedSection, Icons.push_pin_rounded),
            ...pinned.map((note) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildDismissibleCard(context, note),
                )),
            const SizedBox(height: 8),
            _buildSectionHeader(context, context.l10n.allNotesSection, Icons.notes_rounded),
          ],
          ...other.map((note) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildDismissibleCard(context, note),
              )),
        ],
      ),
    );
  }
}
