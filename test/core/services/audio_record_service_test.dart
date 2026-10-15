import 'package:flutter_test/flutter_test.dart';
import 'package:quicknotes/core/services/audio_record_service.dart';
import 'package:record/record.dart';

class FakeAudioRecorder extends Fake implements AudioRecorder {
  bool disposed = false;
  bool permitted = true;

  @override
  Future<bool> hasPermission({bool request = true}) async => permitted;

  @override
  Future<void> dispose() async {
    disposed = true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AudioRecordService Unit Tests', () {
    test('AudioRecordException stores and returns proper message', () {
      const ex = AudioRecordException('Permission denied');
      expect(ex.message, 'Permission denied');
      expect(ex.toString(), 'Permission denied');
    });

    test('AudioRecordService initial state is not recording', () {
      final fakeRecorder = FakeAudioRecorder();
      final service = AudioRecordService(recorder: fakeRecorder);
      expect(service.isRecording, false);
      service.dispose();
      expect(fakeRecorder.disposed, true);
    });

    test('AudioRecordService hasPermission returns fake value', () async {
      final fakeRecorder = FakeAudioRecorder()..permitted = true;
      final service = AudioRecordService(recorder: fakeRecorder);
      expect(await service.hasPermission(), true);
      service.dispose();
    });
  });
}
