import 'package:flutter_test/flutter_test.dart';
import 'package:quicknotes/core/utils/note_export_helper.dart';
import 'package:quicknotes/features/home/model/note_model.dart';
import 'package:quicknotes/features/home/model/subtask_model.dart';

void main() {
  group('NoteExportHelper Tests', () {
    final testNote = Note(
      id: 1,
      title: 'Weekly Sprint Goals',
      body: 'Review client feedback and finalize Q4 deliverables.',
      createdAt: DateTime(2026, 10, 1, 10, 0),
      updatedAt: DateTime(2026, 10, 1, 12, 30),
      tags: const ['work', 'sprint'],
      subtasks: const [
        Subtask(id: '1', title: 'Complete design specs', isCompleted: true),
        Subtask(id: '2', title: 'Merge PR #42', isCompleted: false),
      ],
      latitude: 30.0444,
      longitude: 31.2357,
      reminderAt: DateTime(2026, 10, 10, 9, 0),
    );

    test('formatAsText formats note with all components', () {
      final text = NoteExportHelper.formatAsText(testNote);

      expect(text, contains('Weekly Sprint Goals'));
      expect(text, contains('Tags: #work #sprint'));
      expect(text, contains('Review client feedback'));
      expect(text, contains('Checklist:'));
      expect(text, contains('[x] Complete design specs'));
      expect(text, contains('[ ] Merge PR #42'));
      expect(text, contains('Location: https://www.google.com/maps/search/?api=1&query=30.0444,31.2357'));
      expect(text, contains('Reminder:'));
      expect(text, contains('— Shared via QuickNotes'));
    });

    test('formatAsText handles empty body and untitled notes safely', () {
      final minimalNote = Note(
        id: 2,
        title: '',
        body: '',
        createdAt: DateTime(2026, 10, 1),
        updatedAt: DateTime(2026, 10, 1),
      );

      final text = NoteExportHelper.formatAsText(minimalNote);
      expect(text, contains('Untitled Note'));
      expect(text, contains('— Shared via QuickNotes'));
    });

    test('formatAsMarkdown generates valid markdown with checklist and links', () {
      final md = NoteExportHelper.formatAsMarkdown(testNote);

      expect(md, contains('# Weekly Sprint Goals'));
      expect(md, contains('`#work` `#sprint`'));
      expect(md, contains('### Checklist'));
      expect(md, contains('- [x] Complete design specs'));
      expect(md, contains('- [ ] Merge PR #42'));
      expect(md, contains('[View Location on Google Maps]'));
      expect(md, contains('*Shared via QuickNotes*'));
    });

    test('shareNote calls injected sharing function with formatted text and subject', () async {
      String? capturedText;
      String? capturedSubject;

      await NoteExportHelper.shareNote(
        testNote,
        customShare: (text, {subject}) async {
          capturedText = text;
          capturedSubject = subject;
        },
      );

      expect(capturedText, isNotNull);
      expect(capturedText, contains('Weekly Sprint Goals'));
      expect(capturedSubject, equals('Weekly Sprint Goals'));
    });
  });
}
