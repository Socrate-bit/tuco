import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/model/models.dart';
import '../../call/service/gemini_service.dart';
import '../../call/service/tts_service.dart';

class TranscriptState extends Equatable {
  final List<ChatMessage> messages;
  final int translatingIndex; // message index being translated (-1 none)

  const TranscriptState({
    this.messages = const [],
    this.translatingIndex = -1,
  });

  TranscriptState copyWith({
    List<ChatMessage>? messages,
    int? translatingIndex,
  }) =>
      TranscriptState(
        messages: messages ?? this.messages,
        translatingIndex: translatingIndex ?? this.translatingIndex,
      );

  @override
  List<Object?> get props => [messages, translatingIndex];
}

/// Read-only transcript actions: translate and replay past AI messages.
class TranscriptCubit extends Cubit<TranscriptState> {
  final GeminiService _gemini;
  final TtsService _tts = TtsService();

  TranscriptCubit({
    required UserProfile profile,
    required List<ChatMessage> transcript,
  })  : _gemini = GeminiService(profile: profile, lesson: null),
        super(TranscriptState(messages: transcript)) {
    _tts.init(profile.targetLanguage);
  }

  /// Replay a message with TTS.
  Future<void> playMessage(int index) async {
    try {
      await _tts.speak(state.messages[index].text);
    } catch (e) {
      debugPrint('[TranscriptCubit] play error: $e');
    }
  }

  /// Toggle translation under an AI message (fetches it once).
  Future<void> translateMessage(int index) async {
    final msg = state.messages[index];
    if (msg.translation != null) {
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

  @override
  Future<void> close() {
    _tts.dispose();
    return super.close();
  }
}
