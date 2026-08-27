import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../core/model/app_language.dart';

/// Character voice. Speaks via the `tts` Cloud Function (ElevenLabs proxy,
/// key stays server-side) and falls back to on-device flutter_tts when the
/// call fails. Keeps the cycling speed control (1x → 1.5x → 2x → 0.5x → 0.75x).
class TtsService {
  final HttpsCallable _tts = FirebaseFunctions.instanceFor(
          region: 'europe-west1')
      .httpsCallable('tts',
          options: HttpsCallableOptions(timeout: const Duration(seconds: 20)));

  final AudioPlayer _player = AudioPlayer();
  final FlutterTts _fallback = FlutterTts();
  String _languageCode = 'en';
  int _requestId = 0; // Drops stale responses when speak() is called again.

  static const speeds = [1.0, 1.5, 2.0, 0.5, 0.75];
  int _speedIndex = 0;

  double get speed => speeds[_speedIndex];
  String get speedLabel => switch (speed) {
        1.0 => '1x',
        1.5 => '1.5x',
        2.0 => '2x',
        0.5 => '0.5x',
        _ => '0.75x',
      };

  Future<void> init(String languageCode) async {
    _languageCode = languageCode;
    try {
      // Playback category so audio plays through the speaker even with the
      // ring/silent switch on, and coexists with the speech_to_text session.
      await AudioPlayer.global.setAudioContext(AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: const {AVAudioSessionOptions.mixWithOthers},
        ),
        android: const AudioContextAndroid(
          contentType: AndroidContentType.speech,
          usageType: AndroidUsageType.assistant,
        ),
      ));
      await _player.setReleaseMode(ReleaseMode.stop);
      await _fallback.setLanguage(AppLanguages.of(languageCode).ttsLocale);
      await _fallback.setSpeechRate(0.5);
      await _fallback.awaitSpeakCompletion(true);
      debugPrint('[TtsService] Initialized for $languageCode');
    } catch (e) {
      debugPrint('[TtsService] init error: $e');
    }
  }

  /// Cycle playback speed; returns the new label.
  String cycleSpeed() {
    _speedIndex = (_speedIndex + 1) % speeds.length;
    try {
      _player.setPlaybackRate(speed);
      _fallback.setSpeechRate(0.5 * speed);
    } catch (e) {
      debugPrint('[TtsService] cycleSpeed error: $e');
    }
    return speedLabel;
  }

  Future<void> speak(String text) async {
    await stop();
    final id = ++_requestId;
    try {
      final bytes = await _synthesize(text);
      if (id != _requestId) return; // A newer speak/stop superseded this one.
      // AVPlayer needs a file with an .mp3 extension; BytesSource writes an
      // extensionless cache file that iOS refuses to play.
      final file =
          File('${Directory.systemTemp.path}/tts_${id % 4}.mp3');
      await file.writeAsBytes(bytes, flush: true);
      await _player.setPlaybackRate(speed);
      await _player.play(DeviceFileSource(file.path));
      debugPrint('[TtsService] Playing ${bytes.length} bytes (cloud tts)');
    } catch (e) {
      debugPrint('[TtsService] cloud tts error, falling back: $e');
      if (id == _requestId) await _speakFallback(text);
    }
  }

  /// Speak [text] and complete only when playback has finished (or was
  /// stopped/superseded). Lets callers reveal UI in sync with the audio.
  Future<void> speakAndWait(String text) async {
    await stop();
    final id = ++_requestId;
    try {
      final bytes = await _synthesize(text);
      if (id != _requestId) return; // A newer speak/stop superseded this one.
      final file = File('${Directory.systemTemp.path}/tts_${id % 4}.mp3');
      await file.writeAsBytes(bytes, flush: true);
      await _player.setPlaybackRate(speed);
      // Resolves on natural completion or when stop() halts playback.
      final done = _player.onPlayerStateChanged.firstWhere(
          (s) => s == PlayerState.completed || s == PlayerState.stopped);
      await _player.play(DeviceFileSource(file.path));
      await done;
    } catch (e) {
      debugPrint('[TtsService] speakAndWait error, falling back: $e');
      if (id == _requestId) await _speakFallback(text); // awaits completion
    }
  }

  /// Fetch MP3 audio for [text] via the `tts` Cloud Function.
  Future<Uint8List> _synthesize(String text) async {
    final result = await _tts
        .call<Map<String, dynamic>>({'text': text, 'languageCode': _languageCode});
    return base64Decode(result.data['audio'] as String);
  }

  Future<void> _speakFallback(String text) async {
    try {
      await _fallback.speak(text);
    } catch (e) {
      debugPrint('[TtsService] fallback speak error: $e');
    }
  }

  Future<void> stop() async {
    _requestId++;
    try {
      await _player.stop();
      await _fallback.stop();
    } catch (e) {
      debugPrint('[TtsService] stop error: $e');
    }
  }

  void dispose() {
    stop();
    _player.dispose();
  }
}
