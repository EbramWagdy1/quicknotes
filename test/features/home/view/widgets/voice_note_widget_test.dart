import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quicknotes/features/home/view/widgets/voice_note_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VoiceNotePlayerWidget Tests', () {
    testWidgets('renders player controls and delete button when editable', (tester) async {
      bool deleted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VoiceNotePlayerWidget(
              audioPath: '/dummy/audio/voice.m4a',
              isEditable: true,
              onDelete: () => deleted = true,
            ),
          ),
        ),
      );

      // Play button icon
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

      // Voice note duration
      expect(find.text('00:00 / 00:00'), findsOneWidget);

      // Delete button when isEditable is true
      final deleteBtn = find.byIcon(Icons.delete_outline_rounded);
      expect(deleteBtn, findsOneWidget);

      await tester.tap(deleteBtn);
      await tester.pump();
      expect(deleted, true);
    });

    testWidgets('hides delete button when isEditable is false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VoiceNotePlayerWidget(
              audioPath: '/dummy/audio/voice.m4a',
              isEditable: false,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.delete_outline_rounded), findsNothing);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
      expect(find.text('00:00 / 00:00'), findsOneWidget);
    });
  });
}
