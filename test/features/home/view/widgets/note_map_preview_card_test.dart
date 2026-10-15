import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quicknotes/features/home/model/note_model.dart';
import 'package:quicknotes/features/home/model/subtask_model.dart';
import 'package:quicknotes/features/home/view/widgets/note_map_preview_card.dart';

void main() {
  group('NoteMapPreviewCard Widget Tests', () {
    testWidgets('renders title, body, tags, and badges correctly', (tester) async {
      final now = DateTime.now();
      final note = Note(
        id: 1,
        title: 'Pyramids Visit',
        body: 'Meet at the Sphinx gate at 10 AM',
        latitude: 29.9792,
        longitude: 31.1342,
        isPinned: true,
        isFavorite: true,
        tags: const ['trip', 'giza'],
        createdAt: now,
        updatedAt: now,
      );

      bool closed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteMapPreviewCard(
              note: note,
              onClose: () => closed = true,
            ),
          ),
        ),
      );

      expect(find.text('Pyramids Visit'), findsOneWidget);
      expect(find.text('Meet at the Sphinx gate at 10 AM'), findsOneWidget);
      expect(find.text('#trip'), findsOneWidget);
      expect(find.text('#giza'), findsOneWidget);
      expect(find.byIcon(Icons.push_pin_rounded), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
      expect(find.text('Open Note'), findsOneWidget);
      expect(find.text('Directions'), findsOneWidget);

      // Tap close button
      await tester.tap(find.byIcon(Icons.close_rounded));
      expect(closed, isTrue);
    });

    testWidgets('renders checklist progress bar when subtasks exist', (tester) async {
      final now = DateTime.now();
      final note = Note(
        id: 2,
        title: 'Shopping Checklist',
        body: '',
        latitude: 30.0444,
        longitude: 31.2357,
        subtasks: const [
          Subtask(id: '1', title: 'Apples', isCompleted: true),
          Subtask(id: '2', title: 'Milk', isCompleted: false),
        ],
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteMapPreviewCard(
              note: note,
              onClose: () {},
            ),
          ),
        ),
      );

      expect(find.text('Shopping Checklist'), findsOneWidget);
      expect(find.text('1/2 done'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('renders alarm icon when note has reminderAt', (tester) async {
      final now = DateTime.now();
      final note = Note(
        id: 3,
        title: 'Airport Pickup',
        body: 'Terminal 3',
        latitude: 30.1219,
        longitude: 31.4056,
        reminderAt: now.add(const Duration(hours: 4)),
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteMapPreviewCard(
              note: note,
              onClose: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.alarm_rounded), findsOneWidget);
    });
  });
}
