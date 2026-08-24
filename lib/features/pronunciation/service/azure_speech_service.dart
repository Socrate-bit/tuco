import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../core/model/app_language.dart';
import '../model/pronunciation_result.dart';

/// Calls Azure Speech's short-audio REST API to both recognize speech and
/// score its pronunciation (accuracy / fluency / prosody down to the phoneme).
///
/// DEV ONLY: the subscription key lives here for local testing. Move this
/// behind a Firebase callable (like the ElevenLabs `tts` function) before
/// shipping — a client-embedded key can be extracted from the app binary.
class AzureSpeechService {
  // TODO(pronunciation): move key + host server-side before production.
  static const _key =
      '4O1YYPGNJQUJ9V5QEJ1sTMmT4i8g4CCk85gflOpRjgc0YttCbJD9JQQJ99CHACfhMk5XJ3w3AAAAACOG2wCH';
  static const _host = 'https://swedencentral.stt.speech.microsoft.com';
  static const _path =
      '/speech/recognition/conversation/cognitiveservices/v1';

  /// Assess the pronunciation of the WAV [audio] file.
  ///
  /// Pass [referenceText] for scripted assessment (e.g. single-word practice);
  /// leave it null/empty for unscripted assessment of free conversation, where
  /// Azure also returns the recognized text.
  Future<PronunciationResult?> assess({
    required File audio,
    String? referenceText,
    required String languageCode,
  }) async {
    try {
      final locale = AppLanguages.of(languageCode).ttsLocale; // e.g. es-ES
      final uri = Uri.parse('$_host$_path?language=$locale');

      // Prosody is en-US only; requesting it elsewhere is harmless.
      final params = <String, String>{
        'ReferenceText': referenceText ?? '',
        'GradingSystem': 'HundredMark',
        'Granularity': 'Phoneme',
        'Dimension': 'Comprehensive',
        'EnableProsodyAssessment': 'True',
      };
      final pronHeader = base64.encode(utf8.encode(jsonEncode(params)));

      final bytes = await audio.readAsBytes();
      final resp = await http.post(
        uri,
        headers: {
          'Ocp-Apim-Subscription-Key': _key,
          'Content-Type': 'audio/wav; codecs=audio/pcm; samplerate=16000',
          'Accept': 'application/json',
          'Pronunciation-Assessment': pronHeader,
        },
        body: bytes,
      );

      if (resp.statusCode != 200) {
        debugPrint(
            '[AzureSpeechService] HTTP ${resp.statusCode}: ${resp.body}');
        return null;
      }

      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      final result = PronunciationResult.fromAzureJson(json);
      if (result == null) {
        debugPrint(
            '[AzureSpeechService] No recognition: ${json['RecognitionStatus']}');
      } else {
        debugPrint('[AzureSpeechService] Scored "${result.recognizedText}" '
            '→ ${result.pronScore.round()}');
      }
      return result;
    } catch (e) {
      debugPrint('[AzureSpeechService] assess error: $e');
      return null;
    }
  }
}
