import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Speech input. Wraps speech_to_text for push-to-talk recognition.
class SttService {
  final SpeechToText _stt = SpeechToText();
  bool _ready = false;

  Future<bool> init() async {
    try {
      _ready = await _stt.initialize(
        onError: (e) => debugPrint('[SttService] error: ${e.errorMsg}'),
      );
      debugPrint('[SttService] Initialized: $_ready');
    } catch (e) {
      debugPrint('[SttService] init error: $e');
      _ready = false;
    }
    return _ready;
  }

  bool get isListening => _stt.isListening;

  /// Start listening; [onResult] receives partial + final transcripts.
  Future<void> listen({
    required String languageCode,
    required void Function(String text, bool isFinal) onResult,
  }) async {
    if (!_ready) await init();
    if (!_ready) return;
    try {
      await _stt.listen(
        listenOptions: SpeechListenOptions(
            partialResults: true, localeId: _localeFor(languageCode)),
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

  String _localeFor(String code) => switch (code) {
        'es' => 'es_ES',
        'fr' => 'fr_FR',
        'en' => 'en_US',
        'tr' => 'tr_TR',
        'ar' => 'ar_SA',
        _ => 'en_US',
      };
}
