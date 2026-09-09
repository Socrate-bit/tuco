import 'dart:convert';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

import '../../consent/service/ai_consent_service.dart';
import '../model/pronunciation_result.dart';

/// Scoring granularity — selects the SpeechSuper coreType (single word vs
/// phrase/sentence).
enum SpeechSuperCoreType { word, sentence }

/// Scores a recording against a reference text, down to the phoneme, and
/// returns the [PronunciationResult] the app renders.
///
/// Goes through the `assessPronunciation` Cloud Function, which owns the
/// SpeechSuper credentials, the sha1 signing and the coreType mapping — no key
/// ships in the app binary.
///
/// Scripted-only: SpeechSuper does NOT recognize free speech, so callers must
/// supply [referenceText] — the known word/sentence, or (for free
/// conversation) an Apple transcription used as the reference.
class SpeechSuperService {
  final HttpsCallable _assess = FirebaseFunctions.instanceFor(
          region: 'europe-west1')
      .httpsCallable('assessPronunciation',
          options: HttpsCallableOptions(timeout: const Duration(seconds: 60)));

  /// Assess the pronunciation of the WAV [audio] against [referenceText].
  ///
  /// [coreType] picks word- vs sentence-level scoring; [languageCode] is the
  /// app language ('es', 'fr', 'zh', 'en'). Returns null on any failure.
  Future<PronunciationResult?> assess({
    required File audio,
    required String referenceText,
    required String languageCode,
    SpeechSuperCoreType coreType = SpeechSuperCoreType.sentence,
  }) async {
    // This is the only request that carries the raw recording off the device.
    if (!AiConsentService.allows('speechsuper.assess')) return null;
    final ref = referenceText.trim();
    if (ref.isEmpty) {
      debugPrint('[SpeechSuperService] Empty referenceText — skipping.');
      return null;
    }
    try {
      final response = await _assess.call<Map<String, dynamic>>({
        'audio': base64Encode(await audio.readAsBytes()),
        'referenceText': ref,
        'languageCode': languageCode,
        'granularity': coreType.name,
      });
      // The function returns the raw SpeechSuper body as a string so the
      // nested JSON keeps its types across the platform channel.
      final body = response.data['assessment'] as String? ?? '';
      final json = jsonDecode(body) as Map<String, dynamic>;
      final result =
          PronunciationResult.fromSpeechSuperJson(json, refText: ref);
      if (result == null) {
        debugPrint('[SpeechSuperService] No score: $body');
      } else {
        debugPrint('[SpeechSuperService] Scored "${result.recognizedText}" '
            '→ ${result.pronScore.round()}');
      }
      return result;
    } catch (e) {
      debugPrint('[SpeechSuperService] assess error: $e');
      return null;
    }
  }
}
