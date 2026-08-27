import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../core/model/models.dart';
import '../../../core/service/analytics_service.dart';
import '../../../core/service/data_repository.dart';
import '../../../core/service/sound_service.dart';
import '../../curriculum/model/curriculum_models.dart';
import '../../pronunciation/model/pronunciation_result.dart';
import '../../pronunciation/service/apple_speech_service.dart';
import '../../pronunciation/service/audio_recorder_service.dart';
import '../../pronunciation/service/recording_storage_service.dart';
import '../../pronunciation/service/speech_super_service.dart';
import '../service/gemini_service.dart';
import '../service/stt_service.dart';
import '../service/tts_service.dart';

enum CallPhase { lesson, practice, free }

/// Pending "are you ready to continue?" confirmation before a transition.
enum ContinuePrompt { none, practice, end }

class CallState extends Equatable {
  final List<ChatMessage> messages;
  final CallPhase phase;
  final ContinuePrompt pendingContinue;
  final bool aiThinking;
  final bool aiSpeaking; // Bubbles still being revealed in sync with audio.
  final bool listening; // recording the learner's voice
  final bool assessing; // Azure is recognizing + scoring the recording
  final String partialTranscript;
  final bool typingMode;
  final String ttsSpeedLabel;
  final int elapsedSeconds;
  final bool finished;
  final int translatingIndex; // message index being translated (-1 none)

  const CallState({
    this.messages = const [],
    this.phase = CallPhase.lesson,
    this.pendingContinue = ContinuePrompt.none,
    this.aiThinking = false,
    this.aiSpeaking = false,
    this.listening = false,
    this.assessing = false,
    this.partialTranscript = '',
    this.typingMode = false,
    this.ttsSpeedLabel = '1x',
    this.elapsedSeconds = 0,
    this.finished = false,
    this.translatingIndex = -1,
  });

  CallState copyWith({
    List<ChatMessage>? messages,
    CallPhase? phase,
    ContinuePrompt? pendingContinue,
    bool? aiThinking,
    bool? aiSpeaking,
    bool? listening,
    bool? assessing,
    String? partialTranscript,
    bool? typingMode,
    String? ttsSpeedLabel,
    int? elapsedSeconds,
    bool? finished,
    int? translatingIndex,
  }) =>
      CallState(
        messages: messages ?? this.messages,
        phase: phase ?? this.phase,
        pendingContinue: pendingContinue ?? this.pendingContinue,
        aiThinking: aiThinking ?? this.aiThinking,
        aiSpeaking: aiSpeaking ?? this.aiSpeaking,
        listening: listening ?? this.listening,
        assessing: assessing ?? this.assessing,
        partialTranscript: partialTranscript ?? this.partialTranscript,
        typingMode: typingMode ?? this.typingMode,
        ttsSpeedLabel: ttsSpeedLabel ?? this.ttsSpeedLabel,
        elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
        finished: finished ?? this.finished,
        translatingIndex: translatingIndex ?? this.translatingIndex,
      );

  /// True when a hint was already requested since the last AI message
  /// (one inspiration allowed per message round).
  bool get inspirationUsed {
    for (final m in messages.reversed) {
      if (m.role == MessageRole.inspiration) return true;
      if (m.role == MessageRole.ai && m.banner == null) return false;
    }
    return false;
  }

  @override
  List<Object?> get props => [
        messages,
        phase,
        pendingContinue,
        aiThinking,
        aiSpeaking,
        listening,
        assessing,
        partialTranscript,
        typingMode,
        ttsSpeedLabel,
        elapsedSeconds,
        finished,
        translatingIndex,
      ];
}

/// Drives one call: conversation flow, phases, voice IO and persistence.
class CallCubit extends Cubit<CallState> {
  final DataRepository _repo;
  final UserProfile _profile;
  final AnalyticsService _analytics;
  final Lesson? lesson;
  final SavedSession? _resumeSession;
  final bool _startAtPractice;

  late final GeminiService _gemini;
  final TtsService _tts = TtsService();
  // Kept but unplugged (previously used for live recognition).
  final SttService _stt = SttService();
  final AudioRecorderService _recorder = AudioRecorderService();
  // Apple transcribes the recording; SpeechSuper scores it against that text.
  final AppleSpeechService _apple = AppleSpeechService();
  final SpeechSuperService _speech = SpeechSuperService();
  final RecordingStorageService _recordingStorage = RecordingStorageService();
  Timer? _timer;
  final DateTime _startedAt = DateTime.now();

  CallCubit({
    required DataRepository repo,
    required UserProfile profile,
    required AnalyticsService analytics,
    required this.lesson,
    SavedSession? resumeSession,
    bool startAtPractice = false,
  })  : _repo = repo,
        _profile = profile,
        _analytics = analytics,
        _resumeSession = resumeSession,
        _startAtPractice = startAtPractice,
        super(CallState(
          phase: lesson == null
              ? CallPhase.free
              : (startAtPractice ? CallPhase.practice : CallPhase.lesson),
        )) {
    _gemini = GeminiService(profile: profile, lesson: lesson);
    _init();
  }

  Future<void> _init() async {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isClosed) {
        emit(state.copyWith(
            elapsedSeconds:
                (_resumeSession?.elapsedSeconds ?? 0) +
                    DateTime.now().difference(_startedAt).inSeconds));
      }
    });
    await _tts.init(_profile.targetLanguage);
    await _stt.init();

    // Resume or fresh start.
    if (_resumeSession != null) {
      emit(state.copyWith(
        messages: _resumeSession.transcript,
        phase: _resumeSession.phase == 'practice'
            ? CallPhase.practice
            : CallPhase.lesson,
      ));
      final reply = await _gemini.start(
          startAtPractice: _resumeSession.phase == 'practice',
          history: _resumeSession.transcript);
      _handleAiReply(reply);
      return;
    }

    // Fresh lesson calls open with the "Cours" (or "Entraînement") banner.
    if (lesson != null) {
      _append(ChatMessage(
          role: MessageRole.ai,
          text: '',
          banner: _startAtPractice ? 'practice' : 'course'));
    }
    final reply = await _gemini.start(startAtPractice: _startAtPractice);
    _handleAiReply(reply);
  }

  void _append(ChatMessage m) =>
      emit(state.copyWith(messages: [...state.messages, m]));

  /// Process a tutor reply: strip markers, apply phase transitions, speak.
  Future<void> _handleAiReply(String raw) async {
    var text = raw.trim();
    final win = text.contains(kWinMarker);
    final fail = text.contains(kFailMarker);
    // Never switch phase on a reply that corrects a mistake: the model will
    // re-emit the done marker after the learner's next correct answer.
    final lessonDone = !fail && text.contains(kLessonDoneMarker);
    final practiceDone = !fail && text.contains(kPracticeDoneMarker);
    text = text
        .replaceAll(kLessonDoneMarker, '')
        .replaceAll(kPracticeDoneMarker, '')
        .replaceAll(kWinMarker, '')
        .replaceAll(kFailMarker, '')
        .trim();

    if (win || fail) _applyVerdict(win ? 'win' : 'fail');

    if (text.isNotEmpty) {
      // The model separates ideas with [NEXT]; each part becomes its own
      // bubble, revealed in sync with its audio (next bubble appears once the
      // previous one finished speaking), matching the reference UI.
      final parts = text
          .split(kSplitMarker)
          .map((p) => p.trim())
          .where((p) => p.isNotEmpty)
          .toList();
      // Spinner off as soon as the first bubble shows; aiSpeaking keeps
      // input blocked until the whole reply is revealed.
      emit(state.copyWith(aiThinking: false, aiSpeaking: true));
      for (final part in parts) {
        if (isClosed) return;
        _append(ChatMessage(role: MessageRole.ai, text: part));
        await _tts.speakAndWait(part);
      }
      if (isClosed) return;
      emit(state.copyWith(aiSpeaking: false));
    }

    if (lessonDone) {
      _append(const ChatMessage(
          role: MessageRole.ai, text: '', banner: 'courseDone'));
      // Wait for the learner to confirm before starting the practice phase.
      emit(state.copyWith(
          aiThinking: false, pendingContinue: ContinuePrompt.practice));
      _persistSession();
      return;
    }
    if (practiceDone) {
      // Wait for the learner to confirm before showing the end screen.
      emit(state.copyWith(
          aiThinking: false, pendingContinue: ContinuePrompt.end));
      _persistSession();
      return;
    }
    emit(state.copyWith(aiThinking: false));
    _persistSession();
  }

  /// Learner confirmed the "are you ready to continue?" prompt.
  void confirmContinue() {
    final prompt = state.pendingContinue;
    if (prompt == ContinuePrompt.none) return;
    if (prompt == ContinuePrompt.practice) {
      _append(const ChatMessage(
          role: MessageRole.ai, text: '', banner: 'practice'));
      emit(state.copyWith(
          phase: CallPhase.practice,
          aiThinking: true,
          pendingContinue: ContinuePrompt.none));
      _persistSession();
      _startPractice();
      return;
    }
    emit(state.copyWith(pendingContinue: ContinuePrompt.none));
    _finishLesson();
  }

  /// Tag the learner's latest message with the exercise result and play the
  /// matching sound.
  void _applyVerdict(String verdict) {
    final index =
        state.messages.lastIndexWhere((m) => m.role == MessageRole.user);
    if (index != -1) {
      final msgs = [...state.messages];
      msgs[index] = msgs[index].copyWith(verdict: verdict);
      emit(state.copyWith(messages: msgs));
    }
    verdict == 'win' ? SoundService.playWin() : SoundService.playFail();
    debugPrint('[CallCubit] Exercise verdict: $verdict');
  }

  /// Upload a recording in the background and attach its URL to the message.
  Future<void> _uploadRecording(
      File file, int index, PronunciationResult result) async {
    final url = await _recordingStorage.upload(file);
    if (isClosed || url == null) return;
    updateMessagePronunciation(index, result, url);
  }

  /// Replace a message's pronunciation score + recording after a "try again".
  void updateMessagePronunciation(
      int index, PronunciationResult result, String? recordingUrl) {
    if (index < 0 || index >= state.messages.length) return;
    final msgs = [...state.messages];
    msgs[index] = msgs[index]
        .copyWith(pronunciation: result, recordingUrl: recordingUrl);
    emit(state.copyWith(messages: msgs));
    _persistSession();
    debugPrint('[CallCubit] Updated pronunciation for message $index');
  }

  /// Opens the practice role-play once the learner confirms.
  Future<void> _startPractice() async {
    final reply = await _gemini.send(
        '(The lesson is finished. Start the practice role-play now.)');
    if (isClosed) return;
    _handleAiReply(reply);
  }

  /// Learner sent a message (voice recognition result or typed text).
  /// [pronunciation] is attached when the message came from a scored recording.
  Future<void> sendUserMessage(String text,
      {PronunciationResult? pronunciation, String? recordingUrl}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.aiThinking || state.aiSpeaking) return;
    _append(ChatMessage(
        role: MessageRole.user,
        text: trimmed,
        pronunciation: pronunciation,
        recordingUrl: recordingUrl));
    emit(state.copyWith(
        aiThinking: true, partialTranscript: '', typingMode: false));

    // Fire-and-forget feedback generation.
    _generateFeedback(trimmed);

    final reply = await _gemini.send(trimmed);
    if (isClosed) return;
    _handleAiReply(reply);
  }

  Future<void> _generateFeedback(String text) async {
    final result = await _gemini.feedback(text);
    if (result == null || isClosed) return;
    if (result.corrections.isNotEmpty) {
      await _repo.addFeedback(FeedbackItem(
        id: const Uuid().v4(),
        type: 'grammar',
        lessonId: lesson?.id,
        lessonTitle: lesson?.title,
        originalText: text,
        corrections: result.corrections,
        score: result.score,
        createdAt: DateTime.now(),
      ));
    }
    if (result.alternative != null && result.alternative!.isNotEmpty) {
      await _repo.addFeedback(FeedbackItem(
        id: const Uuid().v4(),
        type: 'alternative',
        lessonId: lesson?.id,
        lessonTitle: lesson?.title,
        originalText: text,
        corrections: [
          Correction(
              wrong: text, right: result.alternative!, explanation: ''),
        ],
        score: result.score,
        createdAt: DateTime.now(),
      ));
    }
  }

  // ---------------- Voice input ----------------

  /// Push-to-talk: first tap records; second tap stops, then Apple transcribes
  /// the speech and SpeechSuper scores it against that transcription before the
  /// turn is sent.
  Future<void> toggleListening() async {
    if (state.assessing) return; // ignore taps while a recording is scored

    if (state.listening) {
      emit(state.copyWith(listening: false));
      final file = await _recorder.stop();
      if (file == null) {
        debugPrint('[CallCubit] No audio captured');
        return;
      }
      emit(state.copyWith(assessing: true));
      // 1) Transcribe the recording (SpeechSuper is scripted, so it needs the
      // spoken text as its reference).
      final text = await _apple.transcribeFile(
        file.path,
        _profile.targetLanguage,
      );
      if (isClosed) return;
      if (text == null || text.isEmpty) {
        emit(state.copyWith(assessing: false));
        debugPrint('[CallCubit] Empty recognition — nothing sent');
        return;
      }
      // 2) Score the pronunciation against the transcription.
      final result = await _speech.assess(
        audio: file,
        referenceText: text,
        languageCode: _profile.targetLanguage,
        coreType: SpeechSuperCoreType.sentence,
      );
      if (isClosed) return;
      emit(state.copyWith(assessing: false));
      if (result != null) {
        _analytics.track('pronunciation_assessed', {
          'score': result.pronScore.round(),
          'words': result.words.length,
          'language': _profile.targetLanguage,
        });
      }
      // Show the message right away; if it was scored, upload the recording in
      // the background and patch its URL in so "listen back" becomes available.
      sendUserMessage(text, pronunciation: result);
      if (result != null) {
        final index =
            state.messages.lastIndexWhere((m) => m.role == MessageRole.user);
        if (index != -1) _uploadRecording(file, index, result);
      }
      return;
    }

    await _tts.stop();
    final started = await _recorder.start();
    if (!started) {
      debugPrint('[CallCubit] Recorder failed to start');
      return;
    }
    emit(state.copyWith(listening: true, partialTranscript: ''));
  }

  /// Discard the current recording and start a fresh one (clear button).
  Future<void> clearTranscript() async {
    if (!state.listening) return;
    await _recorder.cancel();
    final started = await _recorder.start();
    if (!started && !isClosed) emit(state.copyWith(listening: false));
    debugPrint('[CallCubit] Recording restarted (cleared)');
  }

  /// Switch to typing mode; if recording, cancel it without scoring.
  Future<void> switchToTyping() async {
    if (state.listening) {
      await _recorder.cancel();
      emit(state.copyWith(listening: false, partialTranscript: ''));
    }
    emit(state.copyWith(typingMode: true));
  }

  void setTypingMode(bool enabled) =>
      emit(state.copyWith(typingMode: enabled));

  // ---------------- Message actions ----------------

  String toggleTtsSpeed() {
    final label = _tts.cycleSpeed();
    emit(state.copyWith(ttsSpeedLabel: label));
    return label;
  }

  Future<void> replayMessage(int index) =>
      _tts.speak(state.messages[index].text);

  /// Toggle translation under an AI message (fetches it once).
  Future<void> translateMessage(int index) async {
    final msg = state.messages[index];
    if (msg.translation != null) {
      // Toggle off by clearing (keep cached in a fresh object list copy).
      final msgs = [...state.messages];
      msgs[index] = ChatMessage(
          role: msg.role,
          text: msg.text,
          translation: null,
          banner: msg.banner,
          verdict: msg.verdict);
      emit(state.copyWith(messages: msgs));
      return;
    }
    emit(state.copyWith(translatingIndex: index));
    final translation = await _gemini.translate(msg.text);
    if (isClosed) return;
    final msgs = [...state.messages];
    msgs[index] = msg.copyWith(translation: translation);
    emit(state.copyWith(messages: msgs, translatingIndex: -1));
  }

  /// "Inspiration": add an example-sentences bubble (one per message round).
  Future<void> requestInspiration() async {
    if (state.aiThinking || state.aiSpeaking || state.inspirationUsed) {
      debugPrint('[CallCubit] Inspiration blocked (thinking or already used)');
      return;
    }
    final examples = await _gemini.inspiration(state.messages);
    if (isClosed) return;
    _append(ChatMessage(
        role: MessageRole.inspiration, text: examples.join('\n')));
  }

  // ---------------- End of call ----------------

  Future<void> _finishLesson() async {
    _timer?.cancel();
    // Optimistic: open the end screen immediately, persist in the background.
    SoundService.playLessonWin();
    emit(state.copyWith(finished: true));
    await _repo.addCall(CallRecord(
      id: const Uuid().v4(),
      type: 'lesson',
      lessonId: lesson!.id,
      title: lesson!.title,
      startedAt: _startedAt,
      durationSeconds: state.elapsedSeconds,
      transcript: state.messages,
      newWordsCount: lesson!.vocab.length,
      completed: true,
    ));
    await _repo.addLearnedWords([
      for (final w in lesson!.vocab)
        LearnedWord(
            word: w.word,
            translation: w.translation,
            language: _profile.targetLanguage,
            lessonId: lesson!.id,
            learnedAt: DateTime.now()),
    ]);
    await _repo.recordPractice(
        addSeconds: state.elapsedSeconds, lessonCompleted: true);
    await _repo.markLessonCompleted(lesson!.id);
    await _repo.awardLessonCompletion();
    await _repo.deleteSession(lesson!.id);
    debugPrint('[CallCubit] Lesson ${lesson!.id} completed');
  }

  /// User quit mid-call (from the confirmation dialog).
  Future<void> quitCall() async {
    _timer?.cancel();
    await _tts.stop();
    await _stt.stop();
    await _recorder.cancel();
    final hasContent =
        state.messages.any((m) => m.role == MessageRole.user);
    if (hasContent) {
      await _repo.addCall(CallRecord(
        id: const Uuid().v4(),
        type: lesson == null ? 'free' : 'lesson',
        lessonId: lesson?.id,
        title: lesson?.title ?? '',
        startedAt: _startedAt,
        durationSeconds: state.elapsedSeconds,
        transcript: state.messages,
        completed: false,
      ));
      await _repo.recordPractice(addSeconds: state.elapsedSeconds);
    }
    await _persistSession();
    debugPrint('[CallCubit] Call quit after ${state.elapsedSeconds}s');
  }

  /// Free conversation has no marker: ending it saves and finishes.
  Future<void> endFreeConversation() async {
    _timer?.cancel();
    await _repo.addCall(CallRecord(
      id: const Uuid().v4(),
      type: 'free',
      title: '',
      startedAt: _startedAt,
      durationSeconds: state.elapsedSeconds,
      transcript: state.messages,
      completed: true,
    ));
    await _repo.recordPractice(addSeconds: state.elapsedSeconds);
  }

  Future<void> _persistSession() async {
    if (lesson == null || state.finished) return;
    await _repo.saveSession(SavedSession(
      lessonId: lesson!.id,
      transcript: state.messages,
      phase: state.phase == CallPhase.practice ? 'practice' : 'lesson',
      elapsedSeconds: state.elapsedSeconds,
    ));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _tts.dispose();
    _stt.stop();
    _recorder.dispose();
    return super.close();
  }
}
