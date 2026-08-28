import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

/// Captures microphone audio to a 16 kHz mono WAV file — the format the
/// pronunciation-assessment endpoint expects. `speech_to_text` can't hand us
/// the raw audio, so recording is done separately here.
class AudioRecorderService {
  final AudioRecorder _recorder = AudioRecorder();

  bool get isRecording => _isRecording;
  bool _isRecording = false;

  Future<bool> hasPermission() => _recorder.hasPermission();

  /// Start recording to a temp WAV file. Returns false if permission denied
  /// or recording could not start.
  Future<bool> start() async {
    try {
      if (!await _recorder.hasPermission()) {
        debugPrint('[AudioRecorderService] Microphone permission denied');
        return false;
      }
      // Unique filename so a recording pending upload isn't overwritten.
      final path = '${Directory.systemTemp.path}/pron_${const Uuid().v4()}.wav';
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: path,
      );
      _isRecording = true;
      debugPrint('[AudioRecorderService] Recording to $path');
      return true;
    } catch (e) {
      debugPrint('[AudioRecorderService] start error: $e');
      _isRecording = false;
      return false;
    }
  }

  /// Stop recording and return the captured WAV file (null on failure).
  Future<File?> stop() async {
    try {
      final path = await _recorder.stop();
      _isRecording = false;
      if (path == null) return null;
      final file = File(path);
      return await file.exists() ? file : null;
    } catch (e) {
      debugPrint('[AudioRecorderService] stop error: $e');
      _isRecording = false;
      return null;
    }
  }

  /// Discard the current recording without returning it.
  Future<void> cancel() async {
    try {
      await _recorder.cancel();
    } catch (e) {
      debugPrint('[AudioRecorderService] cancel error: $e');
    }
    _isRecording = false;
  }

  void dispose() => _recorder.dispose();
}
