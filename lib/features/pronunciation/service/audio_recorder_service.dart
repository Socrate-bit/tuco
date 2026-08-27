import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

/// Captures microphone audio to a 16 kHz mono WAV file — the format Azure's
/// pronunciation-assessment endpoint expects. `speech_to_text` can't hand us
/// the raw audio, so recording is done separately here.
///
/// Recording is not stopped by the user: once started it auto-stops after a
/// short run of silence (detected via the amplitude stream), so the mic button
/// only ever *starts* a take.
class AudioRecorderService {
  final AudioRecorder _recorder = AudioRecorder();

  bool get isRecording => _isRecording;
  bool _isRecording = false;

  // --- Silence auto-stop tuning ---
  static const _sampleInterval = Duration(milliseconds: 250);
  static const _silenceThresholdDb = -35.0; // below this = "no sound"
  static const _silenceSamples = 12; // ~3s of silence after speech → stop
  static const _noSpeechSamples = 24; // ~6s with no sound at all → stop

  StreamSubscription<Amplitude>? _ampSub;
  bool _hasSpoken = false;
  int _silentCount = 0;
  int _elapsedSamples = 0;

  Future<bool> hasPermission() => _recorder.hasPermission();

  /// Start recording to a temp WAV file. Returns false if permission denied
  /// or recording could not start. When [onSilence] is provided, the recording
  /// auto-stops (fires the callback) after a short silence once the user has
  /// spoken, or after a safety window if no sound is ever detected.
  Future<bool> start({VoidCallback? onSilence}) async {
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
      if (onSilence != null) _monitorSilence(onSilence);
      return true;
    } catch (e) {
      debugPrint('[AudioRecorderService] start error: $e');
      _isRecording = false;
      return false;
    }
  }

  /// Watch the amplitude stream and fire [onSilence] once the take should end.
  void _monitorSilence(VoidCallback onSilence) {
    _hasSpoken = false;
    _silentCount = 0;
    _elapsedSamples = 0;
    _ampSub = _recorder.onAmplitudeChanged(_sampleInterval).listen((amp) {
      _elapsedSamples++;
      final loud = amp.current > _silenceThresholdDb;
      if (loud) {
        _hasSpoken = true;
        _silentCount = 0;
        return;
      }
      // Silent sample: only count down once the user has actually spoken.
      if (_hasSpoken) {
        _silentCount++;
        if (_silentCount >= _silenceSamples) _fireSilence(onSilence);
      } else if (_elapsedSamples >= _noSpeechSamples) {
        // Never heard a sound — stop so the take can't hang open.
        debugPrint('[AudioRecorderService] No speech detected — auto-stopping');
        _fireSilence(onSilence);
      }
    }, onError: (e) {
      debugPrint('[AudioRecorderService] amplitude error: $e');
    });
  }

  void _fireSilence(VoidCallback onSilence) {
    _cancelAmpSub();
    onSilence();
  }

  void _cancelAmpSub() {
    _ampSub?.cancel();
    _ampSub = null;
  }

  /// Stop recording and return the captured WAV file (null on failure).
  Future<File?> stop() async {
    _cancelAmpSub();
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
    _cancelAmpSub();
    try {
      await _recorder.cancel();
    } catch (e) {
      debugPrint('[AudioRecorderService] cancel error: $e');
    }
    _isRecording = false;
  }

  void dispose() {
    _cancelAmpSub();
    _recorder.dispose();
  }
}
