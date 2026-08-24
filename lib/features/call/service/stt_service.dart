import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../core/model/app_language.dart';

/// Speech input. Wraps speech_to_text for push-to-talk recognition.
class SttService {
  final SpeechToText _stt = SpeechToText();
  bool _ready = false;
  // Locales actually installed on the device (from the plugin, populated at
  // init). We match our target language against these so we never hand the
  // recognizer an id it doesn't recognize — otherwise it silently falls back
  // to the device's language and transcribes in the wrong tongue.
  List<LocaleName> _locales = const [];

  Future<bool> init() async {
    try {
      _ready = await _stt.initialize(
        onError: (e) => debugPrint('[SttService] error: ${e.errorMsg}'),
      );
      if (_ready) _locales = await _stt.locales();
      debugPrint('[SttService] Initialized: $_ready (${_locales.length} locales)');
    } catch (e) {
      debugPrint('[SttService] init error: $e');
      _ready = false;
    }
    return _ready;
  }

  bool get isListening => _stt.isListening;

  /// Resolve a target language [code] (e.g. 'es') to a locale id the device
  /// actually has installed. Prefers our exact region tag, then any locale
  /// sharing the language. Returns null when none is installed, so recognition
  /// would fall back to the device locale.
  String? _resolveLocaleId(String code) {
    if (_locales.isEmpty) return null;
    final lang = AppLanguages.of(code);
    // Normalize so 'es-ES' and 'es_ES' (iOS vs Android formats) compare equal.
    String norm(String s) => s.toLowerCase().replaceAll('-', '_');
    final wanted = norm(lang.sttLocale); // e.g. 'es_es'
    final prefix = '${lang.code.toLowerCase()}_'; // e.g. 'es_'

    // 1) Exact region match (our configured locale).
    for (final l in _locales) {
      if (norm(l.localeId) == wanted) return l.localeId;
    }
    // 2) Any installed locale for the same language (e.g. 'es_MX').
    for (final l in _locales) {
      final n = norm(l.localeId);
      if (n == lang.code.toLowerCase() || n.startsWith(prefix)) return l.localeId;
    }
    return null;
  }

  /// Start listening; [onResult] receives partial + final transcripts.
  Future<void> listen({
    required String languageCode,
    required void Function(String text, bool isFinal) onResult,
  }) async {
    if (!_ready) await init();
    if (!_ready) return;
    // Use the device's own id for this language; fall back to our configured
    // tag only if it isn't installed (recognition may then be inaccurate).
    final resolved = _resolveLocaleId(languageCode);
    if (resolved == null) {
      debugPrint('[SttService] No installed locale for "$languageCode"; '
          'recognition may fall back to the device language.');
    }
    final localeId = resolved ?? AppLanguages.of(languageCode).sttLocale;
    try {
      await _stt.listen(
        listenOptions: SpeechListenOptions(
            partialResults: true, localeId: localeId),
        onResult: (r) => onResult(r.recognizedWords, r.finalResult),
      );
    } catch (e) {
      debugPrint('[SttService] listen error: $e');
    }
  }

  /// Stop listening and discard the pending result (no final callback).
  Future<void> cancel() async {
    try {
      await _stt.cancel();
    } catch (e) {
      debugPrint('[SttService] cancel error: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _stt.stop();
    } catch (e) {
      debugPrint('[SttService] stop error: $e');
    }
  }
}
