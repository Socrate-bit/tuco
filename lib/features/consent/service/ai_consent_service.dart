import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Version of the AI disclosure the user agreed to. Bump this whenever the
/// disclosure changes materially (a new provider, new data sent): every user
/// then falls back to "not granted" and is asked again before the next call.
const kAiConsentVersion = 1;

/// Owns the user's permission to send their voice and messages to the external
/// AI providers (Google Gemini, Microsoft Azure AI Speech, SpeechSuper), as
/// required by App Store guidelines 5.1.1(i) / 5.1.2(i).
///
/// Static because [allows] is the single gate every outbound AI request passes
/// through, including from plain services that have no BuildContext. The stored
/// value is the *device's* decision, so a user updating from a version without
/// this screen starts at "not granted" and is asked before their next AI call.
class AiConsentService {
  static const _keyVersion = 'ai_consent_version';
  static const _keyDecidedAt = 'ai_consent_decided_at';

  /// Disclosure version the user last agreed to; 0 when they never did.
  static int _grantedVersion = 0;
  static final StreamController<bool> _changes =
      StreamController<bool>.broadcast();

  /// True only when the user agreed to the *current* disclosure.
  static bool get isGranted => coversVersion(_grantedVersion);

  /// Whether a consent stored at [storedVersion] still covers the disclosure at
  /// [current]. Bumping [kAiConsentVersion] past a stored value closes the gate
  /// again, so the user is re-asked before their next AI request.
  static bool coversVersion(int storedVersion,
          {int current = kAiConsentVersion}) =>
      storedVersion >= current;

  /// Emits on every grant/withdraw so the UI stays reactive.
  static Stream<bool> get changes => _changes.stream;

  /// Reads the stored decision. Called once at startup, before the first frame,
  /// so [allows] is accurate from the very first request.
  static Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _grantedVersion = prefs.getInt(_keyVersion) ?? 0;
      debugPrint('[AiConsentService] Loaded consent v$_grantedVersion '
          '(current v$kAiConsentVersion, granted: $isGranted)');
    } catch (e) {
      debugPrint('[AiConsentService] load error: $e');
      _grantedVersion = 0;
    }
  }

  /// The user agreed to the current disclosure.
  static Future<void> grant() async {
    _grantedVersion = kAiConsentVersion;
    _changes.add(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyVersion, kAiConsentVersion);
      await prefs.setInt(
          _keyDecidedAt, DateTime.now().millisecondsSinceEpoch);
      debugPrint('[AiConsentService] Consent granted (v$kAiConsentVersion)');
    } catch (e) {
      debugPrint('[AiConsentService] grant error: $e');
    }
  }

  /// The user declined, or withdrew a permission they had given. Every AI
  /// request is blocked again from this point on.
  static Future<void> withdraw() async {
    _grantedVersion = 0;
    _changes.add(false);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyVersion);
      await prefs.setInt(
          _keyDecidedAt, DateTime.now().millisecondsSinceEpoch);
      debugPrint('[AiConsentService] Consent withdrawn');
    } catch (e) {
      debugPrint('[AiConsentService] withdraw error: $e');
    }
  }

  /// THE GATE. Every request that would send user data to an external AI
  /// provider calls this first and does nothing when it returns false.
  /// [tag] identifies the blocked call in the logs.
  static bool allows(String tag) {
    if (isGranted) return true;
    debugPrint('[AiConsentService] Blocked "$tag": AI consent not granted');
    return false;
  }

  /// Test seam — resets the in-memory decision without touching storage.
  @visibleForTesting
  static void resetForTest() => _grantedVersion = 0;
}
