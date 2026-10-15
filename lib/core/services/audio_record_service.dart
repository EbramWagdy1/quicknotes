import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class AudioRecordService {
  final AudioRecorder _recorder;
  bool _isRecording = false;

  AudioRecordService({AudioRecorder? recorder})
      : _recorder = recorder ?? AudioRecorder();

  bool get isRecording => _isRecording;

  Future<bool> hasPermission() async {
    try {
      return await _recorder.hasPermission();
    } catch (e) {
      debugPrint('AudioRecordService.hasPermission error: $e');
      return false;
    }
  }

  Future<String> generateAudioPath() async {
    final appDir = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${appDir.path}/audio_notes');
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${audioDir.path}/voice_note_$timestamp.m4a';
  }

  Future<String?> startRecording({String? customPath}) async {
    final permitted = await hasPermission();
    if (!permitted) {
      throw const AudioRecordException('Microphone permission was not granted.');
    }

    final path = customPath ?? await generateAudioPath();

    try {
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );
      _isRecording = true;
      return path;
    } catch (e) {
      _isRecording = false;
      throw AudioRecordException('Failed to start recording: $e');
    }
  }

  Future<String?> stopRecording() async {
    try {
      final path = await _recorder.stop();
      _isRecording = false;
      return path;
    } catch (e) {
      _isRecording = false;
      throw AudioRecordException('Failed to stop recording: $e');
    }
  }

  Future<void> cancelRecording() async {
    try {
      await _recorder.cancel();
    } catch (_) {}
    _isRecording = false;
  }

  void dispose() {
    _recorder.dispose();
  }
}

class AudioRecordException implements Exception {
  final String message;
  const AudioRecordException(this.message);

  @override
  String toString() => message;
}
