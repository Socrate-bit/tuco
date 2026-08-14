import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Plays short feedback sounds (win / fail / lesson completion).
class SoundService {
  SoundService._();

  static final AudioPlayer _player = AudioPlayer();

  /// Correct exercise answer.
  static Future<void> playWin() => _play('songs/win.mp3');

  /// Wrong exercise answer.
  static Future<void> playFail() => _play('songs/faillure.mp3');

  /// Whole lesson completed.
  static Future<void> playLessonWin() => _play('songs/lesson_win.mp3');

  static Future<void> _play(String asset) async {
    try {
      await _player.stop();
      await _player.play(AssetSource(asset));
    } catch (e) {
      debugPrint('[SoundService] play $asset error: $e');
    }
  }
}
