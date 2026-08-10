import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../core/model/models.dart';
import '../../../core/service/data_repository.dart';
import '../../curriculum/model/curriculum_models.dart';
import '../service/gemini_service.dart';
import '../service/stt_service.dart';
import '../service/tts_service.dart';

enum CallPhase { lesson, practice, free }

class CallState extends Equatable {
  final List<ChatMessage> messages;
  final CallPhase phase;
  final bool aiThinking;
  final bool listening;
  final String partialTranscript;
  final bool typingMode;
  final String ttsSpeedLabel;
  final int elapsedSeconds;
  final bool finished;
  final int translatingIndex; // message index being translated (-1 none)

  const CallState({
    this.messages = const [],
    this.phase = CallPhase.lesson,
    this.aiThinking = false,
    this.listening = false,
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
    bool? aiThinking,
    bool? listening,
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
        aiThinking: aiThinking ?? this.aiThinking,
        listening: listening ?? this.listening,
        partialTranscript: partialTranscript ?? this.partialTranscript,
        typingMode: typingMode ?? this.typingMode,
        ttsSpeedLabel: ttsSpeedLabel ?? this.ttsSpeedLabel,
        elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
        finished: finished ?? this.finished,
        translatingIndex: translatingIndex ?? this.translatingIndex,
      );

  @override
  List<Object?> get props => [
        messages,
        phase,
        aiThinking,
        listening,
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
  final Lesson? lesson;
  final SavedSession? _resumeSession;
  final bool _startAtPractice;

  late final GeminiService _gemini;
  final TtsService _tts = TtsService();
  final SttService _stt = SttService();
  Timer? _timer;
  final DateTime _startedAt = DateTime.now();

  CallCubit({
    required DataRepository repo,
    required UserProfile profile,
    required this.lesson,
    SavedSession? resumeSession,
    bool startAtPractice = false,
  })  : _repo = repo,
        _profile = profile,
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
  void _handleAiReply(String raw) {
    var text = raw.trim();
    final lessonDone = text.contains(kLessonDoneMarker);
    final practiceDone = text.contains(kPracticeDoneMarker);
    text = text
        .replaceAll(kLessonDoneMarker, '')
        .replaceAll(kPracticeDoneMarker, '')
        .trim();

    if (text.isNotEmpty) {
      // Split short instruction sentences like `Say "gracias".` into their own
      // bubble, matching the reference UI.
      final sayMatch = RegExp(r'(?:^|\n)(Say "[^"]+"\.)\s*$').firstMatch(text);
      if (sayMatch != null) {
        final instruction = sayMatch.group(1)!;
        final main = text.substring(0, sayMatch.start).trim();
        if (main.isNotEmpty) {
          _append(ChatMessage(role: MessageRole.ai, text: main));
        }
        _append(ChatMessage(role: MessageRole.ai, text: instruction));
      } else {
        _append(ChatMessage(role: MessageRole.ai, text: text));
      }
      _tts.speak(text);
    }

    if (lessonDone) {
      _append(const ChatMessage(
          role: MessageRole.ai, text: '', banner: 'courseDone'));
      _append(const ChatMessage(
          role: MessageRole.ai, text: '', banner: 'practice'));
      emit(state.copyWith(phase: CallPhase.practice));
    }
    if (practiceDone) {
      _finishLesson();
    }
    emit(state.copyWith(aiThinking: false));
    _persistSession();
  }

  /// Learner sent a message (voice final result or typed text).
  Future<void> sendUserMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.aiThinking) return;
    _append(ChatMessage(role: MessageRole.user, text: trimmed));
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

  Future<void> toggleListening() async {
    if (state.listening) {
      await _stt.stop();
      emit(state.copyWith(listening: false));
      if (state.partialTranscript.trim().isNotEmpty) {
        await sendUserMessage(state.partialTranscript);
      }
      return;
    }
    await _tts.stop();
    emit(state.copyWith(listening: true, partialTranscript: ''));
    await _stt.listen(
      languageCode: _profile.targetLanguage,
      onResult: (text, isFinal) {
        if (isClosed) return;
        emit(state.copyWith(partialTranscript: text));
        if (isFinal) {
          emit(state.copyWith(listening: false));
          sendUserMessage(text);
        }
      },
    );
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
          banner: msg.banner);
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

  /// "Inspiration": add an example-sentences bubble.
  Future<void> requestInspiration() async {
    if (state.aiThinking) return;
    final examples = await _gemini.inspiration(state.messages);
    if (isClosed) return;
    _append(ChatMessage(
        role: MessageRole.inspiration, text: examples.join('\n')));
  }

  // ---------------- End of call ----------------

  Future<void> _finishLesson() async {
    _timer?.cancel();
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
            lessonId: lesson!.id,
            learnedAt: DateTime.now()),
    ]);
    await _repo.recordPractice(
        addSeconds: state.elapsedSeconds, lessonCompleted: true);
    await _repo.markLessonCompleted(lesson!.id);
    await _repo.deleteSession(lesson!.id);
    debugPrint('[CallCubit] Lesson ${lesson!.id} completed');
    emit(state.copyWith(finished: true));
  }

  /// User quit mid-call (from the confirmation dialog).
  Future<void> quitCall() async {
    _timer?.cancel();
    await _tts.stop();
    await _stt.stop();
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
    return super.close();
  }
}
