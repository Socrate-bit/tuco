import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/service/analytics_service.dart';
import '../model/pronunciation_result.dart';
import '../service/audio_recorder_service.dart';
import '../service/azure_speech_service.dart';

class WordPracticeState extends Equatable {
  final WordScore word; // latest score for the word
  final bool recording;
  final bool assessing;

  const WordPracticeState({
    required this.word,
    this.recording = false,
    this.assessing = false,
  });

  WordPracticeState copyWith({
    WordScore? word,
    bool? recording,
    bool? assessing,
  }) =>
      WordPracticeState(
        word: word ?? this.word,
        recording: recording ?? this.recording,
        assessing: assessing ?? this.assessing,
      );

  @override
  List<Object?> get props => [word, recording, assessing];
}

/// Drives single-word pronunciation practice: record the word, score it against
/// itself (scripted assessment), and surface the updated phoneme breakdown.
class WordPracticeCubit extends Cubit<WordPracticeState> {
  final AnalyticsService _analytics;
  final String _languageCode;
  final AudioRecorderService _recorder = AudioRecorderService();
  final AzureSpeechService _azure = AzureSpeechService();

  WordPracticeCubit({
    required WordScore initial,
    required String languageCode,
    required AnalyticsService analytics,
  })  : _languageCode = languageCode,
        _analytics = analytics,
        super(WordPracticeState(word: initial));

  /// Push-to-talk for a single word: first tap records, second tap scores.
  Future<void> toggleRecording() async {
    if (state.assessing) return;

    if (state.recording) {
      emit(state.copyWith(recording: false));
      final file = await _recorder.stop();
      if (file == null) return;
      emit(state.copyWith(assessing: true));
      final result = await _azure.assess(
        audio: file,
        referenceText: state.word.word,
        languageCode: _languageCode,
      );
      if (isClosed) return;
      emit(state.copyWith(assessing: false));
      if (result != null && result.words.isNotEmpty) {
        _analytics.track('word_practice', {
          'word': state.word.word,
          'score': result.words.first.accuracyScore.round(),
          'language': _languageCode,
        });
        emit(state.copyWith(word: result.words.first));
      } else {
        debugPrint('[WordPracticeCubit] No score for "${state.word.word}"');
      }
      return;
    }

    final started = await _recorder.start();
    if (!started) return;
    emit(state.copyWith(recording: true));
  }

  @override
  Future<void> close() {
    _recorder.dispose();
    return super.close();
  }
}
