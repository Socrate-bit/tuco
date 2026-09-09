import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../../core/model/app_language.dart';
import '../../consent/service/ai_consent_service.dart';

/// Transcribes a recorded audio file with Apple's on-device Speech framework
/// (`SFSpeechRecognizer`) over a platform channel.
///
/// Used for the live conversation, where there is no reference text: we
/// transcribe the recording here, then feed that text to [SpeechSuperService]
/// as the reference for scoring.
///
/// iOS-only — returns null on other platforms or any failure, so callers can
/// degrade gracefully (e.g. skip scoring rather than crash).
class AppleSpeechService {
  static const _channel = MethodChannel('app/apple_speech');

  /// Transcribe the audio file at [path] in the target [languageCode]
  /// ('es', 'fr', 'pt', 'zh', 'en'). Returns the recognized text, or null when
  /// nothing was recognized / recognition failed.
  Future<String?> transcribeFile(String path, String languageCode) async {
    // Recognition runs on-device whenever the locale supports it, but iOS falls
    // back to Apple's servers when it doesn't — so it sits behind the gate too.
    if (!AiConsentService.allows('apple.transcribe')) return null;
    try {
      final localeId = AppLanguages.of(languageCode).sttLocale; // e.g. es_ES
      final text = await _channel.invokeMethod<String>('transcribeFile', {
        'path': path,
        'localeId': localeId,
      });
      final trimmed = text?.trim() ?? '';
      debugPrint('[AppleSpeechService] Transcribed ($localeId): "$trimmed"');
      return trimmed.isEmpty ? null : trimmed;
    } catch (e) {
      debugPrint('[AppleSpeechService] transcribe error: $e');
      return null;
    }
  }
}
