import 'package:audioplayers/audioplayers.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/service/analytics_service.dart';
import '../../call/service/tts_service.dart';
import '../model/pronunciation_result.dart';
import '../service/audio_recorder_service.dart';
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
    void Function(PronunciationResult result, String? recordingUrl)? onUpdated,
  })  : _languageCode = languageCode,
        _referenceText = referenceText,
        _analytics = analytics,
        _onUpdated = onUpdated,
        super(PronunciationReviewState(
            result: initial, recordingUrl: recordingUrl)) {
    _tts.init(languageCode);
    // Preload a seeded recording (opened from history) so the first "Listen"
    // plays without waiting on the network fetch.
    if (recordingUrl != null) {
      _player.setSource(UrlSource(recordingUrl)).catchError((e) {
        debugPrint('[PronunciationReviewCubit] preload error: $e');
      });
    }
  }

  /// Play a native example of the sentence.
  Future<void> playExample() => _tts.speak(_referenceText);

  /// Listen back to the learner's recording. Prefers the freshly-captured
  /// local file (instant) and falls back to the uploaded URL.
  Future<void> playRecording() async {
    final path = state.localRecordingPath;
    final url = state.recordingUrl;
    if (path == null && url == null) return;
    try {
      await _player.stop();
      await _player.play(path != null ? DeviceFileSource(path) : UrlSource(url!));
    } catch (e) {
      debugPrint('[PronunciationReviewCubit] playback error: $e');
    }
  }

  /// Start a take. Stops any example/listen-back audio, then records; the
  /// recorder auto-stops on silence and finishes via [_finishRecording].
  Future<void> startRecording() async {
    if (state.recording || state.assessing) return;
    await _tts.stop();
    await _player.stop();
    final started = await _recorder.start(onSilence: _finishRecording);
    if (!started) return;
    emit(state.copyWith(recording: true));
  }

  /// Stop the take, expose it for listen-back immediately, then re-score it
  /// against the sentence (scripted), upload the audio and update the transcript.
  Future<void> _finishRecording() async {
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
    if (isClosed) return;
    if (result != null) {
      _analytics.track('pronunciation_retry', {
        'score': result.pronScore.round(),
        'language': _languageCode,
      });
      emit(state.copyWith(result: result, recordingUrl: url, assessing: false));
      _onUpdated?.call(result, url);
    } else {
      emit(state.copyWith(recordingUrl: url, assessing: false));
    }
  }

  @override
  Future<void> close() {
    _recorder.dispose();
    _tts.dispose();
    _player.dispose();
    return super.close();
  }
}
