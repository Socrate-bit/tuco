import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Google / Apple / anonymous sign-in. The session starts anonymous, so
/// providers are linked onto the current user to keep the Firestore data;
/// when the credential already belongs to an account we sign into it instead.
class AuthService {
  static bool _googleReady = false;

  /// Link [credential] to the anonymous user, or sign in when it's taken.
  static Future<void> _linkOrSignIn(AuthCredential credential) async {
    final auth = FirebaseAuth.instance;
    try {
      await auth.currentUser!.linkWithCredential(credential);
      debugPrint('[AuthService] Provider linked to anonymous user');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use' ||
          e.code == 'email-already-in-use' ||
          e.code == 'provider-already-linked') {
        await auth.signInWithCredential(credential);
        debugPrint('[AuthService] Signed into existing account');
      } else {
        rethrow;
      }
    }
  }

  static Future<void> signInWithGoogle() async {
    if (!_googleReady) {
      await GoogleSignIn.instance.initialize();
      _googleReady = true;
    }
    final account = await GoogleSignIn.instance.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null) throw Exception('Google sign-in returned no token');
    await _linkOrSignIn(GoogleAuthProvider.credential(idToken: idToken));
  }

  static Future<void> signInWithApple() async {
    // Random nonce, hashed for Apple, raw for Firebase (replay protection).
    final rawNonce = _randomNonce();
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: sha256.convert(utf8.encode(rawNonce)).toString(),
    );
    final credential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );
    await _linkOrSignIn(credential);
  }

  static String _randomNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }
}
