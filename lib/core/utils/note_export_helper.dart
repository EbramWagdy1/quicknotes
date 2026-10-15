import 'package:quicknotes/core/utils/date_formatter.dart';
import 'package:quicknotes/features/home/model/note_model.dart';
import 'package:share_plus/share_plus.dart';

abstract final class NoteExportHelper {
  const NoteExportHelper._();

  /// Formats a [Note] into a clean, human-readable plain text format.
  static String formatAsText(Note note) {
    final buffer = StringBuffer();

    // Title
    final title = note.title.trim().isNotEmpty ? note.title.trim() : 'Untitled Note';
    buffer.writeln(title);
    buffer.writeln('=' * title.length.clamp(12, 40));

    // Tags
    if (note.tags.isNotEmpty) {
      final tagsString = note.tags.map((t) => '#$t').join(' ');
      buffer.writeln('Tags: $tagsString');
    }

    // Date
    buffer.writeln('Date: ${DateFormatter.format(note.updatedAt)}');

    // Reminder
    if (note.reminderAt != null) {
      buffer.writeln('Reminder: ${DateFormatter.format(note.reminderAt!)}');
    }

    // Location
    if (note.hasLocation) {
      buffer.writeln(
        'Location: https://www.google.com/maps/search/?api=1&query=${note.latitude},${note.longitude}',
      );
    }

    buffer.writeln();

    // Body
    if (note.body.trim().isNotEmpty) {
      buffer.writeln(note.body.trim());
      buffer.writeln();
    }

    // Subtasks Checklist
    if (note.hasSubtasks) {
      buffer.writeln('Checklist:');
      for (final subtask in note.subtasks) {
        final mark = subtask.isCompleted ? '[x]' : '[ ]';
        buffer.writeln('$mark ${subtask.title}');
      }
      buffer.writeln();
    }

    buffer.writeln('— Shared via QuickNotes');
    return buffer.toString().trim();
  }

  /// Formats a [Note] into standard GitHub-Flavored Markdown.
  static String formatAsMarkdown(Note note) {
    final buffer = StringBuffer();

    final title = note.title.trim().isNotEmpty ? note.title.trim() : 'Untitled Note';
    buffer.writeln('# $title\n');

    if (note.tags.isNotEmpty) {
      final tagsString = note.tags.map((t) => '`#$t`').join(' ');
      buffer.writeln('$tagsString\n');
    }

    if (note.reminderAt != null) {
      buffer.writeln('> ⏰ **Reminder:** ${DateFormatter.format(note.reminderAt!)}\n');
    }

    if (note.hasLocation) {
      buffer.writeln(
        '> 📍 [View Location on Google Maps](https://www.google.com/maps/search/?api=1&query=${note.latitude},${note.longitude})\n',
      );
    }

    if (note.body.trim().isNotEmpty) {
      buffer.writeln(note.body.trim());
      buffer.writeln();
    }

    if (note.hasSubtasks) {
      buffer.writeln('### Checklist');
      for (final subtask in note.subtasks) {
        final mark = subtask.isCompleted ? '[x]' : '[ ]';
        buffer.writeln('- $mark ${subtask.title}');
      }
      buffer.writeln();
    }

    buffer.writeln('*Shared via QuickNotes*');
    return buffer.toString().trim();
  }

  /// Shares a note via the system share sheet using [share_plus].
  ///
  /// An optional [customShare] function can be injected for testing.
  static Future<void> shareNote(
    Note note, {
    Future<void> Function(String text, {String? subject})? customShare,
  }) async {
    final formatted = formatAsText(note);
    final subject = note.title.trim().isNotEmpty ? note.title.trim() : 'QuickNotes Note';

    if (customShare != null) {
      await customShare(formatted, subject: subject);
    } else {
      await SharePlus.instance.share(ShareParams(
        text: formatted,
        subject: subject,
      ));
    }
  }
}
