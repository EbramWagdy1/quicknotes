import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quicknotes/features/home/model/subtask_model.dart';
import 'package:quicknotes/features/home/view/widgets/subtasks_editor.dart';

void main() {
  group('SubtasksEditor Widget Tests', () {
    testWidgets('renders existing subtasks with completion counts', (
      tester,
    ) async {
      final subtasks = [
        const Subtask(id: '1', title: 'Task Alpha', isCompleted: true),
        const Subtask(id: '2', title: 'Task Beta', isCompleted: false),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SubtasksEditor(subtasks: subtasks, onChanged: (_) {}),
          ),
        ),
      );

      expect(find.text('Checklist & Sub-tasks'), findsOneWidget);
      expect(find.text('1 of 2 done'), findsOneWidget);
      expect(find.text('Task Alpha'), findsOneWidget);
      expect(find.text('Task Beta'), findsOneWidget);
    });

    testWidgets('toggling custom checkbox triggers onChanged callback', (
      tester,
    ) async {
      final subtasks = [
        const Subtask(id: '1', title: 'Task Alpha', isCompleted: false),
      ];
      List<Subtask>? updatedResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SubtasksEditor(
              subtasks: subtasks,
              onChanged: (updated) {
                updatedResult = updated;
              },
            ),
          ),
        ),
      );

      // Tap on the checkbox item
      final checkboxFinder = find.byType(GestureDetector).first;
      await tester.tap(checkboxFinder);
      await tester.pumpAndSettle();

      expect(updatedResult, isNotNull);
      expect(updatedResult!.first.isCompleted, true);
    });

    testWidgets('adding new subtask triggers onChanged callback', (
      tester,
    ) async {
      final subtasks = <Subtask>[];
      List<Subtask>? updatedResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SubtasksEditor(
              subtasks: subtasks,
              onChanged: (updated) {
                updatedResult = updated;
              },
            ),
          ),
        ),
      );

      // Enter text
      final inputFinder = find.byType(TextField);
      await tester.enterText(inputFinder, 'New Test Item');

      // Tap add button
      final addBtnFinder = find.byTooltip('Add sub-task');
      await tester.tap(addBtnFinder);
      await tester.pumpAndSettle();

      expect(updatedResult, isNotNull);
      expect(updatedResult!.length, 1);
      expect(updatedResult!.first.title, 'New Test Item');
    });

    testWidgets('deleting subtask removes item', (tester) async {
      final subtasks = [
        const Subtask(id: '1', title: 'To Delete', isCompleted: false),
      ];
      List<Subtask>? updatedResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SubtasksEditor(
              subtasks: subtasks,
              onChanged: (updated) {
                updatedResult = updated;
              },
            ),
          ),
        ),
      );

      // Tap close/delete icon
      final deleteIconFinder = find.byIcon(Icons.close_rounded);
      await tester.tap(deleteIconFinder);
      await tester.pumpAndSettle();

      expect(updatedResult, isNotNull);
      expect(updatedResult!.isEmpty, true);
    });
  });
}
