import 'package:flutter_test/flutter_test.dart';
import 'package:quicknotes/features/home/model/subtask_model.dart';

void main() {
  group('Subtask Model Tests', () {
    test('creates subtask with default values', () {
      const subtask = Subtask(id: '1', title: 'Buy groceries');
      expect(subtask.id, '1');
      expect(subtask.title, 'Buy groceries');
      expect(subtask.isCompleted, false);
    });

    test('copyWith updates properties properly', () {
      const subtask = Subtask(id: '1', title: 'Task 1', isCompleted: false);
      final updated = subtask.copyWith(
        isCompleted: true,
        title: 'Updated Task',
      );

      expect(updated.id, '1');
      expect(updated.title, 'Updated Task');
      expect(updated.isCompleted, true);
    });

    test('serializes to and from JSON correctly', () {
      const subtask = Subtask(
        id: 'task-123',
        title: 'Fix bug',
        isCompleted: true,
      );
      final json = subtask.toJson();

      expect(json['id'], 'task-123');
      expect(json['title'], 'Fix bug');
      expect(json['isCompleted'], true);

      final deserialized = Subtask.fromJson(json);
      expect(deserialized, subtask);
    });

    test('fromJson handles null or missing values safely', () {
      final subtask = Subtask.fromJson(const {});
      expect(subtask.id, '');
      expect(subtask.title, '');
      expect(subtask.isCompleted, false);
    });
  });
}
