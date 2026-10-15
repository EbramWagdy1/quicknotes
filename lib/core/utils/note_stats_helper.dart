import 'package:quicknotes/features/home/model/note_model.dart';

class NoteStats {
  final int totalActiveNotes;
  final int pinnedCount;
  final int favoriteCount;
  final int lockedCount;
  final int notesWithRemindersCount;
  final int totalSubtasks;
  final int completedSubtasks;
  final double taskCompletionPercentage;
  final Map<String, int> tagDistribution;
  final int trashNotesCount;

  const NoteStats({
    required this.totalActiveNotes,
    required this.pinnedCount,
    required this.favoriteCount,
    required this.lockedCount,
    required this.notesWithRemindersCount,
    required this.totalSubtasks,
    required this.completedSubtasks,
    required this.taskCompletionPercentage,
    required this.tagDistribution,
    required this.trashNotesCount,
  });
}

abstract final class NoteStatsHelper {
  const NoteStatsHelper._();

  static NoteStats calculate({
    required List<Note> activeNotes,
    required List<Note> trashNotes,
  }) {
    int pinned = 0;
    int favorite = 0;
    int locked = 0;
    int reminders = 0;
    int totalTasks = 0;
    int completedTasks = 0;
    final Map<String, int> tagsMap = {};

    for (final note in activeNotes) {
      if (note.isPinned) pinned++;
      if (note.isFavorite) favorite++;
      if (note.isLocked) locked++;
      if (note.hasReminder) reminders++;

      if (note.hasSubtasks) {
        totalTasks += note.subtasks.length;
        completedTasks += note.completedSubtasksCount;
      }

      for (final tag in note.tags) {
        tagsMap[tag] = (tagsMap[tag] ?? 0) + 1;
      }
    }

    final double completionRate = totalTasks > 0
        ? (completedTasks / totalTasks) * 100.0
        : 0.0;

    // Sort tags by frequency descending
    final sortedTags = Map.fromEntries(
      tagsMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );

    return NoteStats(
      totalActiveNotes: activeNotes.length,
      pinnedCount: pinned,
      favoriteCount: favorite,
      lockedCount: locked,
      notesWithRemindersCount: reminders,
      totalSubtasks: totalTasks,
      completedSubtasks: completedTasks,
      taskCompletionPercentage: completionRate,
      tagDistribution: sortedTags,
      trashNotesCount: trashNotes.length,
    );
  }
}
