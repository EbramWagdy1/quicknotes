import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quicknotes/core/localization/generated/app_localizations.dart';
import 'package:quicknotes/core/utils/app_colors.dart';
import 'package:quicknotes/core/utils/app_text_style.dart';
import 'package:quicknotes/features/home/model/note_model.dart';
import 'package:quicknotes/features/home/view_model/cubit/notes_cubit.dart';

/// Global root ScaffoldMessenger key so SnackBars appear reliably even
/// during widget unmounting or navigation transitions.
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class SnackbarHelper {
  SnackbarHelper._();

  static Timer? _dismissTimer;

  /// Displays a floating Undo SnackBar for exactly 5 seconds whenever a note is deleted.
  /// Includes an explicit Timer fallback to guarantee dismissal even when Android
  /// accessibility services or accessibleNavigation suppress SnackBarAction timeouts.
  static void showDeleteUndoSnackBar({
    BuildContext? context,
    required Note note,
    required NotesCubit cubit,
  }) {
    final messenger = rootScaffoldMessengerKey.currentState ??
        ((context != null && context.mounted)
            ? ScaffoldMessenger.maybeOf(context)
            : null);

    if (messenger == null) return;

    _dismissTimer?.cancel();
    messenger.clearSnackBars();

    final resolvedContext = (context != null && context.mounted)
        ? context
        : rootScaffoldMessengerKey.currentContext;
    final l10n = resolvedContext != null ? AppLocalizations.of(resolvedContext) : null;
    final undoLabel = l10n?.undo ?? 'Undo';
    final deletedMessage = note.title.trim().isNotEmpty
        ? (l10n?.noteTitleDeleted(note.title.trim()) ??
            'Note "${note.title.trim()}" deleted')
        : (l10n?.noteDeleted ?? 'Note deleted');

    const snackDuration = Duration(seconds: 5);

    final controller = messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.slate900,
        duration: snackDuration,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Row(
          children: [
            const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.cardWhite,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                deletedMessage,
                style: const TextStyle(
                  fontFamily: AppTextStyle.fontFamily,
                  color: AppColors.cardWhite,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: undoLabel,
          textColor: AppColors.skyBlue,
          onPressed: () {
            _dismissTimer?.cancel();
            messenger.clearSnackBars();
            cubit.restoreNote(note);
          },
        ),
      ),
    );

    // Guaranteed auto-dismissal after duration
    _dismissTimer = Timer(snackDuration, () {
      try {
        controller.close();
      } catch (_) {
        messenger.clearSnackBars();
      }
    });
  }
}
