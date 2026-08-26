import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

/// Uploads voice recordings to Firebase Storage so they can be played back
/// later ("listen to your recording"), including from call history.
class RecordingStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload [wav] and return its download URL, or null on failure. Failure is
  /// non-fatal — scoring still works, the recording just won't be replayable.
  Future<String?> upload(File wav) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anon';
      final ref = _storage.ref('recordings/$uid/${const Uuid().v4()}.wav');
      await ref.putFile(
        wav,
        SettableMetadata(contentType: 'audio/wav'),
      );
      final url = await ref.getDownloadURL();
      debugPrint('[RecordingStorageService] Uploaded recording');
      return url;
    } catch (e) {
      debugPrint('[RecordingStorageService] upload error: $e');
      return null;
    }
  }
}
