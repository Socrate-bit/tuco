import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuco/features/consent/service/ai_consent_service.dart';

/// Stands in for an AI service: it only performs its request when the gate
/// lets it through, exactly like GeminiService / TtsService / SpeechSuperService.
class _FakeAiClient {
  int requests = 0;

  /// Mirrors the guard placement in the real services.
  String? send(String payload) {
    if (!AiConsentService.allows('fake.send')) return null;
    requests++;
    return 'sent: $payload';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeAiClient client;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    AiConsentService.resetForTest();
    client = _FakeAiClient();
  });

  group('AiConsentService gate', () {
    test('blocks the request when consent was never given', () async {
      await AiConsentService.load();

      expect(AiConsentService.isGranted, isFalse);
      expect(client.send('hello'), isNull);
      expect(client.requests, 0);
    });

    test('lets the request through once consent is granted', () async {
      await AiConsentService.load();
      await AiConsentService.grant();

      expect(AiConsentService.isGranted, isTrue);
      expect(client.send('hello'), 'sent: hello');
      expect(client.requests, 1);
    });

    test('blocks again after the user withdraws consent', () async {
      await AiConsentService.load();
      await AiConsentService.grant();
      client.send('first');

      await AiConsentService.withdraw();

      expect(AiConsentService.isGranted, isFalse);
      expect(client.send('second'), isNull);
      expect(client.requests, 1); // only the pre-withdrawal request went out
    });

    test('a granted decision survives a restart', () async {
      await AiConsentService.load();
      await AiConsentService.grant();

      // Relaunch: fresh in-memory state, same stored preferences.
      AiConsentService.resetForTest();
      await AiConsentService.load();

      expect(AiConsentService.isGranted, isTrue);
      expect(client.send('hello'), isNotNull);
    });

    test('existing users updating from a build without the screen are blocked',
        () async {
      // No ai_consent_* key at all — what an app updated over an older install
      // looks like.
      SharedPreferences.setMockInitialValues({'onboarding_complete': true});
      AiConsentService.resetForTest();
      await AiConsentService.load();

      expect(AiConsentService.isGranted, isFalse);
      expect(client.send('hello'), isNull);
    });

    test('a disclosure version bump invalidates the stored consent', () {
      // A user who agreed to the disclosure shipping today...
      expect(AiConsentService.coversVersion(kAiConsentVersion), isTrue);
      // ...no longer covers it once the disclosure is revised.
      expect(
          AiConsentService.coversVersion(kAiConsentVersion,
              current: kAiConsentVersion + 1),
          isFalse,
          reason: 'a revised disclosure must close the gate and re-prompt');
    });

    test('re-granting after a version bump re-opens the gate', () async {
      // Stored one disclosure behind whatever ships today.
      SharedPreferences.setMockInitialValues(
          {'ai_consent_version': kAiConsentVersion - 1});
      AiConsentService.resetForTest();
      await AiConsentService.load();

      expect(AiConsentService.isGranted, isFalse);
      expect(client.send('hello'), isNull);

      await AiConsentService.grant();

      expect(AiConsentService.isGranted, isTrue);
      expect(client.send('hello'), isNotNull);
      expect(client.requests, 1);
    });

    test('consent stored at a newer version still counts as granted', () async {
      // Downgrade / rollback: the user agreed to a broader disclosure.
      SharedPreferences.setMockInitialValues(
          {'ai_consent_version': kAiConsentVersion + 1});
      AiConsentService.resetForTest();
      await AiConsentService.load();

      expect(AiConsentService.isGranted, isTrue);
    });

    test('grant and withdraw are broadcast to listeners', () async {
      await AiConsentService.load();
      final seen = <bool>[];
      final sub = AiConsentService.changes.listen(seen.add);

      await AiConsentService.grant();
      await AiConsentService.withdraw();
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(seen, [true, false]);
    });
  });
}
