import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../model/pronunciation_result.dart';

/// Scoring granularity — selects the SpeechSuper coreType (single word vs
/// phrase/sentence).
enum SpeechSuperCoreType { word, sentence }

/// Calls SpeechSuper's scripted pronunciation-assessment REST API to score a
/// recording against a reference text, down to the phoneme, and returns the
/// same [PronunciationResult] the app already renders.
///
/// Scripted-only: unlike Azure it does NOT recognize free speech, so callers
/// must supply [referenceText] — the known word/sentence, or (for free
/// conversation) an Apple transcription used as the reference.
///
/// DEV ONLY: the app + secret keys live here for local testing. Move the
/// signature behind a Firebase callable (like the ElevenLabs `tts` function)
/// before shipping — client-embedded keys can be extracted from the app binary.
class SpeechSuperService {
  // TODO(pronunciation): move keys + signing server-side before production.
  static const _appKey = '178779427700089b';
  static const _secretKey = '46fb74ac2c8ac69984608c5793b64426';
  static const _host = 'api.speechsuper.com';

  /// App language code → (word coreType, sentence coreType). SpeechSuper's
  /// names are non-uniform per language, so map them explicitly — adding a
  /// language is one row. Only Spanish is enabled on the current trial key.
  static const _coreTypes = <String, (String, String)>{
    'es': ('word.eval.sp', 'sent.eval.sp'),
    'fr': ('word.eval.fr', 'sent.eval.fr'),
    'zh': ('word.eval.cn', 'sent.eval.cn'),
    'en': ('word.eval.promax', 'sent.eval.promax'),
  };

  String _coreTypeFor(String languageCode, SpeechSuperCoreType type) {
    final pair = _coreTypes[languageCode];
    if (pair == null) {
      debugPrint('[SpeechSuperService] No coreType for "$languageCode"; '
          'falling back to English.');
    }
    final (word, sentence) = pair ?? _coreTypes['en']!;
    return type == SpeechSuperCoreType.word ? word : sentence;
  }

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
    final ref = referenceText.trim();
    if (ref.isEmpty) {
      debugPrint('[SpeechSuperService] Empty referenceText — skipping.');
      return null;
    }
    try {
      final core = _coreTypeFor(languageCode, coreType);
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'uid';
      final tokenId = timestamp;

      // Signatures: sha1 over appKey+timestamp(+userId)+secretKey.
      String sign(String data) => sha1.convert(utf8.encode(data)).toString();
      final connectSig = sign('$_appKey$timestamp$_secretKey');
      final startSig = sign('$_appKey$timestamp$userId$_secretKey');

      final params = {
        'connect': {
          'cmd': 'connect',
          'param': {
            'sdk': {'version': 16777472, 'source': 9, 'protocol': 2},
            'app': {
              'applicationId': _appKey,
              'sig': connectSig,
              'timestamp': timestamp,
            },
          },
        },
        'start': {
          'cmd': 'start',
          'param': {
            'app': {
              'applicationId': _appKey,
              'sig': startSig,
              'userId': userId,
              'timestamp': timestamp,
            },
            'audio': {
              'audioType': 'wav',
              'sampleRate': 16000,
              'channel': 1,
              'sampleBytes': 2,
            },
            'request': {
              'coreType': core,
              'refText': ref,
              'tokenId': tokenId,
              'phoneme_output': 1, // request phoneme-level scores
            },
          },
        },
      };

      final uri = Uri.https(_host, core);
      final request = http.MultipartRequest('POST', uri)
        ..fields['text'] = jsonEncode(params)
        ..files.add(await http.MultipartFile.fromPath('audio', audio.path))
        ..headers['Request-Index'] = '0';

      final streamed = await request.send();
      final body = await streamed.stream.transform(utf8.decoder).join();
      if (streamed.statusCode != 200) {
        debugPrint('[SpeechSuperService] HTTP ${streamed.statusCode}: $body');
        return null;
      }

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
