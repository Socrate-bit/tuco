import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Keeps voice recordings on disk so listening back never waits on the network.
///
/// Two ways in: [register] maps a Storage URL to the local file we just
/// uploaded (free — the bytes are already there), and [fetch] downloads a
/// recording once for takes that only exist remotely (e.g. call history).
class RecordingCacheService {
  static final Map<String, String> _paths = {}; // url -> local file
  static final Map<String, Future<String?>> _inflight = {}; // dedupes fetches

  /// Remember the local file that was uploaded to [url] — no download needed.
  static void register(String url, String localPath) {
    _paths[url] = localPath;
  }

  /// Local file for [url] if it is cached and still on disk, else null.
  static String? cached(String url) {
    final path = _paths[url];
    if (path == null) return null;
    if (File(path).existsSync()) return path;
    _paths.remove(url); // temp file was reclaimed by the OS
    return null;
  }

  /// Download [url] into the temp dir once and return the local path (null on
  /// failure). Concurrent callers share a single in-flight download.
  static Future<String?> fetch(String url) {
    final hit = cached(url);
    if (hit != null) return Future.value(hit);
    return _inflight[url] ??= _download(url).whenComplete(() {
      _inflight.remove(url);
    });
  }

  static Future<String?> _download(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        debugPrint('[RecordingCacheService] fetch failed ${response.statusCode}');
        return null;
      }
      final file = File(
          '${Directory.systemTemp.path}/rec_${url.hashCode.toUnsigned(32)}.wav');
      await file.writeAsBytes(response.bodyBytes, flush: true);
      _paths[url] = file.path;
      debugPrint('[RecordingCacheService] Cached ${response.bodyBytes.length} bytes');
      return file.path;
    } catch (e) {
      debugPrint('[RecordingCacheService] fetch error: $e');
      return null;
    }
  }
}
