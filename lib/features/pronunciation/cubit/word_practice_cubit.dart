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

class WordPracticeState extends Equatable {
  final WordScore word; // latest score for the word
  final String? recordingUrl; // set once the recording is uploaded
  final String? localRecordingPath; // set the instant the take is captured
  final bool recording;
  final bool assessing;

  const WordPracticeState({
    required this.word,
    this.recordingUrl,
    this.localRecordingPath,
    this.recording = false,
    this.assessing = false,
  });

  // Listen-back works off the local file immediately, then the uploaded URL.
  bool get canListen => localRecordingPath != null || recordingUrl != null;

  WordPracticeState copyWith({
    WordScore? word,
    String? recordingUrl,
    String? localRecordingPath,
    bool? recording,
    bool? assessing,
  }) =>
      WordPracticeState(
        word: word ?? this.word,
        recordingUrl: recordingUrl ?? this.recordingUrl,
        localRecordingPath: localRecordingPath ?? this.localRecordingPath,
        recording: recording ?? this.recording,
        assessing: assessing ?? this.assessing,
      );

  @override
  List<Object?> get props =>
      [word, recordingUrl, localRecordingPath, recording, assessing];
}

/// Drives single-word pronunciation practice: play a native example, record the
/// word, score it against itself (scripted), upload the audio and let the
/// learner listen back.
class WordPracticeCubit extends Cubit<WordPracticeState> {
  final AnalyticsService _analytics;
  final String _languageCode;
  final AudioRecorderService _recorder = AudioRecorderService();
  final SpeechSuperService _speech = SpeechSuperService();
  final RecordingStorageService _storage = RecordingStorageService();
  final TtsService _tts = TtsService();
  final AudioPlayer _player = AudioPlayer();

  WordPracticeCubit({
    required WordScore initial,
    required String languageCode,
    required AnalyticsService analytics,
  })  : _languageCode = languageCode,
        _analytics = analytics,
        super(WordPracticeState(word: initial)) {
    _tts.init(languageCode);
  }

  /// Play a native example of the word.
  Future<void> playExample() => _tts.speak(state.word.word);

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
      debugPrint('[WordPracticeCubit] playback error: $e');
    }
  }

  /// Push-to-talk for a single word: first tap records, second tap scores it
  /// (scripted), uploads the audio and enables listen-back.
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
        referenceText: state.word.word,
        languageCode: _languageCode,
        coreType: SpeechSuperCoreType.word,
      );
      final url = await _storage.upload(file);
      // Reuse the bytes we just uploaded rather than fetching them back.
      if (url != null) RecordingCacheService.register(url, file.path);
      if (isClosed) return;
      if (result != null && result.words.isNotEmpty) {
        _analytics.track('word_practice', {
          'word': state.word.word,
          'score': result.words.first.accuracyScore.round(),
          'language': _languageCode,
        });
        emit(state.copyWith(
            word: result.words.first, recordingUrl: url, assessing: false));
      } else {
        debugPrint('[WordPracticeCubit] No score for "${state.word.word}"');
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
