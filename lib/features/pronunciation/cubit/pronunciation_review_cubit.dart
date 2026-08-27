import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/service/analytics_service.dart';
import '../../call/service/tts_service.dart';
import '../model/pronunciation_result.dart';
import '../service/audio_recorder_service.dart';
import '../service/recording_cache_service.dart';
import '../service/recording_storage_service.dart';
import '../service/speech_super_service.dart';

class PronunciationReviewState extends Equatable {
  final PronunciationResult result;
  final String? recordingUrl;
  final String? localRecordingPath; // set the instant a new take is captured
  final bool recording;
  final bool assessing;

  const PronunciationReviewState({
    required this.result,
    this.recordingUrl,
    this.localRecordingPath,
    this.recording = false,
    this.assessing = false,
  });

  // Listen-back works off the local file immediately, then the uploaded URL.
  bool get canListen => localRecordingPath != null || recordingUrl != null;

  PronunciationReviewState copyWith({
    PronunciationResult? result,
    String? recordingUrl,
    String? localRecordingPath,
    bool? recording,
    bool? assessing,
  }) =>
      PronunciationReviewState(
        result: result ?? this.result,
        recordingUrl: recordingUrl ?? this.recordingUrl,
        localRecordingPath: localRecordingPath ?? this.localRecordingPath,
        recording: recording ?? this.recording,
        assessing: assessing ?? this.assessing,
      );

  @override
  List<Object?> get props =>
      [result, recordingUrl, localRecordingPath, recording, assessing];
}

/// Drives the message pronunciation review: replay the example, listen back to
/// the recording, and "try again" (scripted re-scoring against the sentence).
class PronunciationReviewCubit extends Cubit<PronunciationReviewState> {
  final String _languageCode;
  final String _referenceText;
  final AnalyticsService _analytics;
  // Called after a successful re-score so the transcript can be updated.
  final void Function(PronunciationResult result, String? recordingUrl)?
      _onUpdated;

  final AudioRecorderService _recorder = AudioRecorderService();
  final SpeechSuperService _speech = SpeechSuperService();
  final RecordingStorageService _storage = RecordingStorageService();
  final TtsService _tts = TtsService();
  final AudioPlayer _player = AudioPlayer();

  PronunciationReviewCubit({
    required PronunciationResult initial,
    required String? recordingUrl,
    required String languageCode,
    required String referenceText,
    required AnalyticsService analytics,
    String? localRecordingPath,
    void Function(PronunciationResult result, String? recordingUrl)? onUpdated,
  })  : _languageCode = languageCode,
        _referenceText = referenceText,
        _analytics = analytics,
        _onUpdated = onUpdated,
        super(PronunciationReviewState(
          result: initial,
          recordingUrl: recordingUrl,
          // The cache wins: after a re-take the message still points at the
          // previous take's temp file, while the cache tracks the current URL.
          localRecordingPath:
              _localFor(recordingUrl) ?? _existing(localRecordingPath),
        )) {
    _tts.init(languageCode);
    _cacheRecording();
  }

  /// Local copy of [url] if one is already on disk (just uploaded or fetched).
  static String? _localFor(String? url) =>
      url == null ? null : RecordingCacheService.cached(url);

  /// [path] if it still exists — temp files can be reclaimed by the OS.
  static String? _existing(String? path) =>
      path != null && File(path).existsSync() ? path : null;

  /// Download the recording as soon as the sheet opens so the first "Listen"
  /// plays instantly instead of waiting on the network.
  Future<void> _cacheRecording() async {
    final url = state.recordingUrl;
    if (url == null || state.localRecordingPath != null) return;
    final path = await RecordingCacheService.fetch(url);
    if (path == null || isClosed) return;
    emit(state.copyWith(localRecordingPath: path));
  }

  /// Play a native example of the sentence.
  Future<void> playExample() => _tts.speak(_referenceText);

  /// Listen back to the learner's recording. Prefers a local copy (instant)
  /// and falls back to streaming the uploaded URL.
  Future<void> playRecording() async {
    final path =
        _existing(state.localRecordingPath) ?? _localFor(state.recordingUrl);
    final url = state.recordingUrl;
    if (path == null && url == null) return;
    try {
      await _player.stop();
      await _player
          .play(path != null ? DeviceFileSource(path) : UrlSource(url!));
    } catch (e) {
      debugPrint('[PronunciationReviewCubit] playback error: $e');
    }
  }

  /// Push-to-talk re-scoring: first tap records, second tap scores against the
  /// sentence (scripted), uploads the audio and updates the transcript.
  Future<void> toggleRecording() async {
    if (state.assessing) return;

    if (state.recording) {
      final file = await _recorder.stop();
      if (isClosed) return;
      if (file == null) {
        emit(state.copyWith(recording: false));
        return;
      }
      // Local file first so listen-back is available before scoring/upload.
      emit(state.copyWith(
          recording: false, assessing: true, localRecordingPath: file.path));
      final result = await _speech.assess(
        audio: file,
        referenceText: _referenceText,
        languageCode: _languageCode,
        coreType: SpeechSuperCoreType.sentence,
      );
      final url = await _storage.upload(file);
      // Reuse the bytes we just uploaded rather than fetching them back.
      if (url != null) RecordingCacheService.register(url, file.path);
      if (isClosed) return;
      if (result != null) {
        _analytics.track('pronunciation_retry', {
          'score': result.pronScore.round(),
          'language': _languageCode,
        });
        emit(
            state.copyWith(result: result, recordingUrl: url, assessing: false));
        _onUpdated?.call(result, url);
      } else {
        emit(state.copyWith(recordingUrl: url, assessing: false));
      }
      return;
    }

    // Stop any example / listen-back audio before recording.
    await _tts.stop();
    await _player.stop();
    final started = await _recorder.start();
    if (!started) return;
    emit(state.copyWith(recording: true));
  }

  @override
  Future<void> close() {
    _recorder.dispose();
    _tts.dispose();
    _player.dispose();
    return super.close();
  }
}
