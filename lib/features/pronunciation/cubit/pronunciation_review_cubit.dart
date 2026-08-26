import 'package:audioplayers/audioplayers.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/service/analytics_service.dart';
import '../../call/service/tts_service.dart';
import '../model/pronunciation_result.dart';
import '../service/audio_recorder_service.dart';
import '../service/azure_speech_service.dart';
import '../service/recording_storage_service.dart';

class PronunciationReviewState extends Equatable {
  final PronunciationResult result;
  final String? recordingUrl;
  final bool recording;
  final bool assessing;

  const PronunciationReviewState({
    required this.result,
    this.recordingUrl,
    this.recording = false,
    this.assessing = false,
  });

  bool get canListen => recordingUrl != null;

  PronunciationReviewState copyWith({
    PronunciationResult? result,
    String? recordingUrl,
    bool? recording,
    bool? assessing,
  }) =>
      PronunciationReviewState(
        result: result ?? this.result,
        recordingUrl: recordingUrl ?? this.recordingUrl,
        recording: recording ?? this.recording,
        assessing: assessing ?? this.assessing,
      );

  @override
  List<Object?> get props => [result, recordingUrl, recording, assessing];
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
  final AzureSpeechService _azure = AzureSpeechService();
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
  }

  /// Play a native example of the sentence.
  Future<void> playExample() => _tts.speak(_referenceText);

  /// Listen back to the learner's recording.
  Future<void> playRecording() async {
    final url = state.recordingUrl;
    if (url == null) return;
    try {
      await _player.stop();
      await _player.play(UrlSource(url));
    } catch (e) {
      debugPrint('[PronunciationReviewCubit] playback error: $e');
    }
  }

  /// Push-to-talk re-scoring: records, then scores against the sentence
  /// (scripted), uploads the audio and updates the transcript.
  Future<void> toggleRecording() async {
    if (state.assessing) return;

    if (state.recording) {
      emit(state.copyWith(recording: false));
      final file = await _recorder.stop();
      if (file == null) return;
      emit(state.copyWith(assessing: true));
      final result = await _azure.assess(
        audio: file,
        referenceText: _referenceText,
        languageCode: _languageCode,
      );
      final url = await _storage.upload(file);
      if (isClosed) return;
      if (result != null) {
        _analytics.track('pronunciation_retry', {
          'score': result.pronScore.round(),
          'language': _languageCode,
        });
        emit(state.copyWith(
            result: result, recordingUrl: url, assessing: false));
        _onUpdated?.call(result, url);
      } else {
        emit(state.copyWith(recordingUrl: url, assessing: false));
      }
      return;
    }

    await _tts.stop();
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
