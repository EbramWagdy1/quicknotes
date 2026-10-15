import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quicknotes/features/home/model/note_model.dart';
import 'package:quicknotes/features/home/model/subtask_model.dart';
import 'package:quicknotes/features/stats/view/productivity_stats_sheet.dart';

void main() {
  group('ProductivityStatsSheet Widget Tests', () {
    testWidgets('renders all productivity metrics and close button works', (tester) async {
      final now = DateTime.now();
      final activeNotes = [
        Note(
          id: 1,
          title: 'Work Sprint',
          body: 'Sprint tasks',
          createdAt: now,
          updatedAt: now,
          isPinned: true,
          isFavorite: true,
          tags: const ['work', 'urgent'],
          subtasks: const [
            Subtask(id: 's1', title: 'Task 1', isCompleted: true),
            Subtask(id: 's2', title: 'Task 2', isCompleted: false),
          ],
          reminderAt: now.add(const Duration(hours: 3)),
        ),
        Note(
          id: 2,
          title: 'Ideas Note',
          body: 'Personal ideas',
          createdAt: now,
          updatedAt: now,
          tags: const ['work'],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  ProductivityStatsSheet.show(
                    context,
                    activeNotes: activeNotes,
                    trashNotes: [],
                  );
                },
                child: const Text('Open Stats'),
              ),
            ),
          ),
        ),
      );

      // Tap to open sheet
      await tester.tap(find.text('Open Stats'));
      await tester.pumpAndSettle();

      // Verify header
      expect(find.text('Productivity & Insights'), findsOneWidget);
      expect(find.text('Overview of your notes, tasks, and tags'), findsOneWidget);

      // Verify task completion
      expect(find.text('Tasks Completion'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
      expect(find.text('1 of 2 checklist tasks completed'), findsOneWidget);

      // Verify metric labels
      expect(find.text('Active Notes'), findsOneWidget);
      expect(find.text('Reminders'), findsOneWidget);
      expect(find.text('Favorites / Pinned'), findsOneWidget);
      expect(find.text('In Trash'), findsOneWidget);

      // Verify values
      expect(find.text('2'), findsWidgets); // Active notes count
      expect(find.text('1'), findsWidgets); // Reminders count
      expect(find.text('1 / 1'), findsOneWidget); // Favorites / Pinned

      // Verify tags
      expect(find.text('Top Tags'), findsOneWidget);
      expect(find.text('#work'), findsOneWidget);
      expect(find.text('#urgent'), findsOneWidget);

      // Tap close button
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      // Sheet should be dismissed
      expect(find.text('Productivity & Insights'), findsNothing);
    });

    testWidgets('renders empty state message when no notes or tasks exist', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProductivityStatsSheet(
              activeNotes: [],
              trashNotes: [],
            ),
          ),
        ),
      );

      expect(find.text('Productivity & Insights'), findsOneWidget);
      expect(find.text('0%'), findsOneWidget);
      expect(find.text('No checklist tasks added yet'), findsOneWidget);
      expect(find.text('Active Notes'), findsOneWidget);
      expect(find.text('Top Tags'), findsNothing);
    });
  });
}
