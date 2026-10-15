import 'package:flutter_test/flutter_test.dart';
import 'package:quicknotes/core/utils/validators.dart';

void main() {
  group('Validators Unit Tests', () {
    test('validateTitle checks empty and length limits', () {
      expect(Validators.validateTitle(''), 'Title cannot be empty');
      expect(Validators.validateTitle('   '), 'Title cannot be empty');
      expect(Validators.validateTitle('A' * 101), contains('cannot exceed'));
      expect(Validators.validateTitle('Valid Title'), isNull);
    });

    test('validateBody permits empty body when hasAudio is true', () {
      expect(Validators.validateBody(''), 'Body cannot be empty');
      expect(Validators.validateBody('', isChecklist: true), isNull);
      expect(Validators.validateBody('', hasAudio: true), isNull);
      expect(Validators.validateBody('Some text', hasAudio: true), isNull);
      expect(Validators.validateBody('A' * 5001), contains('cannot exceed'));
    });
  });
}
