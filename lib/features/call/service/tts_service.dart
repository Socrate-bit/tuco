import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../core/model/app_language.dart';

/// Character voice, backed by Azure AI Speech behind two Cloud Functions —
/// the key stays server-side either way.
///
/// Playback normally streams from `ttsStream`, so the voice starts at Azure's
/// first byte (~0.6s) instead of after the whole clip (~1.4s). When a bubble
/// has been [prefetch]ed via the buffered `tts` callable its audio is already
/// in hand and plays instantly. Falls back to on-device flutter_tts if both
/// fail. Keeps the cycling speed control (1x → 1.5x → 2x → 0.5x → 0.75x).
class TtsService {
  static const _region = 'europe-west1';

  /// Above this, the text no longer fits comfortably in a URL, so streaming
  /// is skipped in favour of the buffered callable. Conversation bubbles are
  /// far shorter; this only guards pathological replies.
  static const _maxStreamChars = 800;

  final HttpsCallable _tts = FirebaseFunctions.instanceFor(region: _region)
      .httpsCallable('tts',
          options: HttpsCallableOptions(timeout: const Duration(seconds: 20)));

  final AudioPlayer _player = AudioPlayer();
  final FlutterTts _fallback = FlutterTts();
  String _languageCode = 'en';
  int _requestId = 0; // Drops stale responses when speak() is called again.

  // Audio for an upcoming bubble, fetched while the current one plays.
  String? _prefetchedText;
  Future<Uint8List>? _prefetchedBytes;

  // Mirrors the player: true only while the voice is actually audible.
  final StreamController<bool> _speaking = StreamController<bool>.broadcast();
  StreamSubscription<PlayerState>? _playerSub;
  bool _isSpeaking = false;

  /// Emits true when Tuco's voice starts and false when it stops — drives the
  /// talking avatar so the mouth moves exactly while audio plays.
  Stream<bool> get speaking => _speaking.stream;

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
    _playerSub ??= _player.onPlayerStateChanged
        .listen((s) => _emitSpeaking(s == PlayerState.playing));
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

  /// Speak [text] without waiting for it to finish.
  Future<void> speak(String text) => _speak(text, wait: false);

  /// Speak [text] and complete only when playback has finished (or was
  /// stopped/superseded). Lets callers reveal UI in sync with the audio.
  ///
  /// [prefetchNext] is fetched in the background once this bubble starts
  /// playing, so the following one begins with no synthesis wait at all.
  Future<void> speakAndWait(String text, {String? prefetchNext}) =>
      _speak(text, wait: true, prefetchNext: prefetchNext);

  Future<void> _speak(String text,
      {required bool wait, String? prefetchNext}) async {
    // Claim any prefetched audio before stop() discards it.
    final prefetched = _takePrefetched(text);
    await stop();
    final id = ++_requestId;
    try {
      final source = await _sourceFor(text, prefetched, id);
      if (source == null || id != _requestId) return; // Superseded.
      await _player.setPlaybackRate(speed);
      // Subscribe before play() so a short clip can't finish unnoticed.
      final done = wait ? _awaitPlayback() : null;
      await _player.play(source);
      // Playback is under way; warming the next bubble no longer competes
      // with this one for bandwidth, and stop() has already run.
      if (prefetchNext != null) _prefetch(prefetchNext);
      if (done != null) await done;
    } catch (e) {
      debugPrint('[TtsService] cloud tts error, falling back: $e');
      if (id == _requestId) await _speakFallback(text);
    }
  }

  /// Pick the cheapest way to play [text]: already-fetched bytes, else a
  /// streaming URL, else the buffered callable. Returns null if superseded.
  Future<Source?> _sourceFor(
      String text, Future<Uint8List>? prefetched, int id) async {
    if (prefetched != null) {
      final bytes = await prefetched;
      if (id != _requestId) return null;
      if (bytes.isNotEmpty) {
        debugPrint('[TtsService] Playing ${bytes.length} bytes (prefetched)');
        return DeviceFileSource(await _writeTemp(bytes, id));
      }
      // Prefetch failed — fall through and fetch it now.
    }
    if (text.length <= _maxStreamChars) {
      final url = await _streamUrl(text);
      if (id != _requestId) return null;
      if (url != null) {
        debugPrint('[TtsService] Streaming "${_preview(text)}"');
        return UrlSource(url, mimeType: 'audio/mpeg');
      }
    }
    final bytes = await _synthesize(text);
    if (id != _requestId) return null;
    debugPrint('[TtsService] Playing ${bytes.length} bytes (buffered)');
    return DeviceFileSource(await _writeTemp(bytes, id));
  }

  /// AVPlayer needs a file with an .mp3 extension; BytesSource writes an
  /// extensionless cache file that iOS refuses to play.
  Future<String> _writeTemp(Uint8List bytes, int id) async {
    final file = File('${Directory.systemTemp.path}/tts_${id % 4}.mp3');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  /// URL of the `ttsStream` endpoint for [text]. The player cannot set request
  /// headers, so the Firebase ID token travels as a query parameter; the
  /// function verifies it. Returns null when there is no signed-in user.
  Future<String?> _streamUrl(String text) async {
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (token == null) return null;
      final projectId = Firebase.app().options.projectId;
      return Uri.https('$_region-$projectId.cloudfunctions.net', '/ttsStream', {
        'token': token,
        'text': text,
        'lang': _languageCode,
      }).toString();
    } catch (e) {
      debugPrint('[TtsService] stream url error: $e');
      return null;
    }
  }

  /// Resolve when playback finishes, or throw if it never started — a stream
  /// that fails to open would otherwise leave the caller waiting forever.
  Future<void> _awaitPlayback() {
    final completer = Completer<void>();
    var started = false;
    final watchdog = Timer(const Duration(seconds: 15), () {
      if (!started && !completer.isCompleted) {
        completer.completeError(TimeoutException('playback never started'));
      }
    });
    final sub = _player.onPlayerStateChanged.listen((s) {
      if (s == PlayerState.playing) started = true;
      if (s == PlayerState.completed || s == PlayerState.stopped) {
        if (!completer.isCompleted) completer.complete();
      }
    });
    return completer.future.whenComplete(() {
      watchdog.cancel();
      sub.cancel();
    });
  }

  /// Start fetching [text] so the next bubble plays with no synthesis wait.
  /// Buffered rather than streamed: the delay is hidden behind the bubble
  /// currently playing, and the bytes must be ready in advance.
  void _prefetch(String text) {
    if (_prefetchedText == text) return;
    _prefetchedText = text;
    // Failures surface as empty bytes and are retried at play time.
    _prefetchedBytes = _synthesize(text).catchError((Object e) {
      debugPrint('[TtsService] prefetch failed: $e');
      return Uint8List(0);
    });
  }

  /// Hand over the prefetched audio for [text], if that is what was warmed.
  Future<Uint8List>? _takePrefetched(String text) {
    if (_prefetchedText != text) return null;
    final bytes = _prefetchedBytes;
    _prefetchedText = null;
    _prefetchedBytes = null;
    return bytes;
  }

  /// Fetch the whole MP3 for [text] via the `tts` Cloud Function. The language
  /// is always sent: the voice auto-detects, but guesses English for short
  /// Spanish inputs.
  Future<Uint8List> _synthesize(String text) async {
    final result = await _tts
        .call<Map<String, dynamic>>({'text': text, 'languageCode': _languageCode});
    return base64Decode(result.data['audio'] as String);
  }

  Future<void> _speakFallback(String text) async {
    try {
      // awaitSpeakCompletion(true) makes this resolve when the voice ends, so
      // the avatar's mouth tracks the fallback engine too.
      _emitSpeaking(true);
      await _fallback.speak(text);
    } catch (e) {
      debugPrint('[TtsService] fallback speak error: $e');
    } finally {
      _emitSpeaking(false);
    }
  }

  /// Broadcast a speaking change once, ignoring repeats.
  void _emitSpeaking(bool value) {
    if (_isSpeaking == value || _speaking.isClosed) return;
    _isSpeaking = value;
    _speaking.add(value);
  }

  String _preview(String text) =>
      text.length <= 40 ? text : '${text.substring(0, 40)}…';

  Future<void> stop() async {
    _requestId++;
    _prefetchedText = null;
    _prefetchedBytes = null;
    _emitSpeaking(false);
    try {
      await _player.stop();
      await _fallback.stop();
    } catch (e) {
      debugPrint('[TtsService] stop error: $e');
    }
  }

  void dispose() {
    stop();
    _playerSub?.cancel();
    _speaking.close();
    _player.dispose();
  }
}
