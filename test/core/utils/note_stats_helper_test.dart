import 'package:flutter_test/flutter_test.dart';
import 'package:quicknotes/core/utils/note_stats_helper.dart';
import 'package:quicknotes/features/home/model/note_model.dart';
import 'package:quicknotes/features/home/model/subtask_model.dart';

void main() {
  group('NoteStatsHelper Tests', () {
    test('calculate returns accurate counts for active and trash notes', () {
      final activeNotes = [
        Note(
          id: 1,
          title: 'Note 1',
          body: 'Body 1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isPinned: true,
          isFavorite: true,
          tags: const ['work', 'design'],
          subtasks: const [
            Subtask(id: '1', title: 'Task 1', isCompleted: true),
            Subtask(id: '2', title: 'Task 2', isCompleted: false),
          ],
        ),
        Note(
          id: 2,
          title: 'Note 2',
          body: 'Body 2',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isPinned: true,
          isLocked: true,
          reminderAt: DateTime.now().add(const Duration(days: 1)),
          tags: const ['work'],
          subtasks: const [
            Subtask(id: '3', title: 'Task 3', isCompleted: true),
            Subtask(id: '4', title: 'Task 4', isCompleted: true),
          ],
        ),
      ];

      final trashNotes = [
        Note(
          id: 3,
          title: 'Deleted Note',
          body: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final stats = NoteStatsHelper.calculate(
        activeNotes: activeNotes,
        trashNotes: trashNotes,
      );

      expect(stats.totalActiveNotes, equals(2));
      expect(stats.pinnedCount, equals(2));
      expect(stats.favoriteCount, equals(1));
      expect(stats.lockedCount, equals(1));
      expect(stats.notesWithRemindersCount, equals(1));
      expect(stats.totalSubtasks, equals(4));
      expect(stats.completedSubtasks, equals(3));
      expect(stats.taskCompletionPercentage, equals(75.0));
      expect(stats.trashNotesCount, equals(1));
      expect(stats.tagDistribution['work'], equals(2));
      expect(stats.tagDistribution['design'], equals(1));
    });

    test('calculate handles empty collections gracefully without division by zero', () {
      final stats = NoteStatsHelper.calculate(
        activeNotes: [],
        trashNotes: [],
      );

      expect(stats.totalActiveNotes, equals(0));
      expect(stats.totalSubtasks, equals(0));
      expect(stats.completedSubtasks, equals(0));
      expect(stats.taskCompletionPercentage, equals(0.0));
      expect(stats.tagDistribution, isEmpty);
      expect(stats.trashNotesCount, equals(0));
    });
  });
}
