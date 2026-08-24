import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../core/model/app_language.dart';

/// Robot voice. Wraps flutter_tts with target-language voice and
/// the cycling speed control (1x → 0.75x → 0.5x).
class TtsService {
  final FlutterTts _tts = FlutterTts();
  static const speeds = [1.0, 0.75, 0.5];
  int _speedIndex = 0;

  double get speed => speeds[_speedIndex];
  String get speedLabel => switch (_speedIndex) {
        0 => '1x',
        1 => '0.75x',
        _ => '0.5x',
      };

  Future<void> init(String languageCode) async {
    try {
      await _tts.setLanguage(AppLanguages.of(languageCode).ttsLocale);
      await _tts.setSpeechRate(0.5); // flutter_tts default-ish natural rate
      await _tts.awaitSpeakCompletion(true);
      debugPrint('[TtsService] Initialized for $languageCode');
    } catch (e) {
      debugPrint('[TtsService] init error: $e');
    }
  }

  /// Cycle playback speed; returns the new label.
  String cycleSpeed() {
    _speedIndex = (_speedIndex + 1) % speeds.length;
    try {
      _tts.setSpeechRate(0.5 * speed);
    } catch (e) {
      debugPrint('[TtsService] setSpeechRate error: $e');
    }
    return speedLabel;
  }

  Future<void> speak(String text) async {
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (e) {
      debugPrint('[TtsService] speak error: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (e) {
      debugPrint('[TtsService] stop error: $e');
    }
  }

  void dispose() => stop();
}
