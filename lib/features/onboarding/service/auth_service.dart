import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Email / password sign-in for existing accounts, offered on the start page.
/// Signing in replaces the anonymous session with the account's own uid, so the
/// account's Firestore document — including its `user_type` tier — is what the
/// app reads from that point on.
class AuthService {
  /// Signs into an existing account. Throws [FirebaseAuthException] on bad
  /// credentials so the caller can show the failure message.
  static Future<void> signInWithEmail(String email, String password) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    debugPrint('[AuthService] Signed in with email');
  }
}
