import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../../core/model/models.dart';
import '../../curriculum/model/curriculum_models.dart';

/// Marker the model emits when the teaching phase is finished.
const kLessonDoneMarker = '[LESSON_DONE]';

/// Marker the model emits when the practice phase is finished.
const kPracticeDoneMarker = '[PRACTICE_DONE]';

/// Gemini-backed tutor. Handles the conversation, translations, inspiration
/// suggestions and grammar/alternative feedback. Falls back to a scripted
/// offline tutor when Firebase isn't configured, so the app stays usable.
class GeminiService {
  final bool available;
  final UserProfile profile;
  final Lesson? lesson;

  ChatSession? _chat;

  // Scripted fallback state.
  int _scriptStep = -1;

  GeminiService({required this.profile, required this.lesson})
      : available = Firebase.apps.isNotEmpty;

  String get _nativeName => switch (profile.nativeLanguage) {
        'fr' => 'French',
        'es' => 'Spanish',
        'tr' => 'Turkish',
        'ar' => 'Arabic',
        _ => 'English',
      };

  String get _targetName => switch (profile.targetLanguage) {
        'es' => 'Spanish',
        'fr' => 'French',
        'en' => 'English',
        _ => 'Spanish',
      };

  GenerativeModel _model({String? systemPrompt, bool json = false}) =>
      FirebaseAI.googleAI().generativeModel(
        model: 'gemini-2.5-flash',
        systemInstruction:
            systemPrompt != null ? Content.system(systemPrompt) : null,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          responseMimeType: json ? 'application/json' : 'text/plain',
        ),
      );

  /// Build the tutor system prompt for the current call.
  String _tutorPrompt({required bool startAtPractice}) {
    final explainLang = profile.studyInNativeLanguage ? _nativeName : _targetName;
    final base = '''
You are the AI language tutor of the app Learna, on a voice call with ${profile.name}.
Target language: $_targetName. The learner's native language is $_nativeName. Level: ${profile.level}.
Explain and give instructions in $explainLang. Keep every message short (1-3 sentences), warm and encouraging. Never use emojis or markdown.
Learner interests: ${profile.interests.join(', ')}.''';

    if (lesson == null) {
      return '''$base
This is a FREE CONVERSATION. Chat naturally in simple $_targetName adapted to the learner's level, gently correcting when needed. Start by greeting the learner and proposing a topic.''';
    }

    final vocabList =
        lesson!.vocab.map((w) => '${w.word} = ${w.translation}').join('; ');
    final phase = startAtPractice
        ? 'Start directly at the PRACTICE phase (skip teaching).'
        : 'Start with the LESSON phase.';
    return '''$base
This call teaches the lesson "${lesson!.title}" (${lesson!.description}).
Lesson vocabulary: $vocabList.
Grammar focus: ${lesson!.grammarPoints.join('; ')}.

The call has two phases:
1. LESSON phase: greet the learner by name, announce today's topic and list the words you'll learn, then ask "Does that sound good? Please say yes or no.". Teach the vocabulary words one at a time: introduce the word, its meaning, then ask the learner to say it (e.g. Say "gracias".). Acknowledge each attempt. After ALL words are taught, cover the grammar focus briefly. When the whole lesson content is done, end your message with the exact marker $kLessonDoneMarker
2. PRACTICE phase: have a short role-play conversation using ONLY the lesson material. Tell the learner: you'll only use material from the lesson. After about 6 learner turns, congratulate and end your message with the exact marker $kPracticeDoneMarker

$phase''';
  }

  /// Start (or resume) the tutor chat and return the first AI message.
  Future<String> start({
    required bool startAtPractice,
    List<ChatMessage> history = const [],
  }) async {
    if (!available) return _scriptedReply(null);
    try {
      final model = _model(systemPrompt: _tutorPrompt(startAtPractice: startAtPractice));
      _chat = model.startChat(
        history: [
          for (final m in history.where((m) => m.banner == null))
            m.role == MessageRole.user
                ? Content.text(m.text)
                : Content.model([TextPart(m.text)]),
        ],
      );
      if (history.isNotEmpty) {
        // Resuming: ask the tutor to pick the lesson back up.
        final resp = await _chat!
            .sendMessage(Content.text('(I am back, please continue the lesson where we left off.)'));
        return resp.text ?? '';
      }
      final resp = await _chat!.sendMessage(Content.text('(The call just started, greet me.)'));
      return resp.text ?? '';
    } catch (e) {
      debugPrint('[GeminiService] start error: $e');
      return _scriptedReply(null);
    }
  }

  /// Send the learner's message; returns the tutor reply (may contain markers).
  Future<String> send(String userText) async {
    if (!available || _chat == null) return _scriptedReply(userText);
    try {
      final resp = await _chat!.sendMessage(Content.text(userText));
      return resp.text ?? '';
    } catch (e) {
      debugPrint('[GeminiService] send error: $e');
      return _scriptedReply(userText);
    }
  }

  /// Translate [text] to the learner's native language.
  Future<String> translate(String text) async {
    if (!available) return text;
    try {
      final resp = await _model().generateContent([
        Content.text(
            'Translate the following message to $_nativeName. Reply with the translation only:\n$text')
      ]);
      return resp.text?.trim() ?? text;
    } catch (e) {
      debugPrint('[GeminiService] translate error: $e');
      return text;
    }
  }

  /// Suggest example replies for the learner ("Inspiration" button).
  Future<List<String>> inspiration(List<ChatMessage> history) async {
    if (!available) return ['Estoy listo para empezar.'];
    try {
      final lastAi = history.lastWhere(
        (m) => m.role == MessageRole.ai && m.banner == null,
        orElse: () => const ChatMessage(role: MessageRole.ai, text: ''),
      );
      final resp = await _model(json: true).generateContent([
        Content.text(
            'A $_targetName learner (level ${profile.level}) must reply to their tutor message: "${lastAi.text}". '
            'Give 1 or 2 short example replies in $_targetName. '
            'Reply as JSON: {"examples": ["..."]}')
      ]);
      final map = jsonDecode(resp.text ?? '{}') as Map<String, dynamic>;
      return (map['examples'] as List?)?.cast<String>() ??
          ['Estoy listo para empezar.'];
    } catch (e) {
      debugPrint('[GeminiService] inspiration error: $e');
      return ['Estoy listo para empezar.'];
    }
  }

  /// Grammar + alternative feedback for a learner sentence.
  /// Returns null when the sentence needs no feedback (or on failure).
  Future<({int score, List<Correction> corrections, String? alternative})?>
      feedback(String userText) async {
    if (!available) return null;
    // Skip trivial one-word answers.
    if (userText.trim().split(RegExp(r'\s+')).length < 2) return null;
    try {
      final resp = await _model(json: true).generateContent([
        Content.text(
            'You are a $_targetName teacher. Analyse this learner sentence: "$userText". '
            'If it is not in $_targetName or too trivial, reply {"skip": true}. Otherwise reply as JSON: '
            '{"score": 0-100, "corrections": [{"wrong": "...", "right": "...", "explanation": "... (in $_nativeName)"}], '
            '"alternative": "a more natural way to phrase it, or null if already natural"}. '
            'corrections lists each wrong word/group with its fix; empty list if perfect.')
      ]);
      final map = jsonDecode(resp.text ?? '{}') as Map<String, dynamic>;
      if (map['skip'] == true) return null;
      return (
        score: (map['score'] as num?)?.toInt() ?? 100,
        corrections: ((map['corrections'] as List?) ?? [])
            .map((c) => Correction.fromMap(Map<String, dynamic>.from(c)))
            .toList(),
        alternative: map['alternative'] as String?,
      );
    } catch (e) {
      debugPrint('[GeminiService] feedback error: $e');
      return null;
    }
  }

  // ---------------- Scripted offline fallback ----------------

  /// Walks the lesson vocab so the whole flow works without Firebase.
  String _scriptedReply(String? userText) {
    final l = lesson;
    if (l == null) {
      return "Hi ${profile.name}! I'm your Learna tutor. Firebase isn't configured yet, but let's chat! ¿Cómo estás?";
    }
    _scriptStep++;
    if (_scriptStep == 0) {
      final words = l.vocab.map((w) => w.translation).join(', ');
      return "Hi ${profile.name}! Today, we'll learn ${l.description.toLowerCase().replaceAll('.', '')} in $_targetName. "
          "We'll use words like $words. Does that sound good? Please say yes or no.";
    }
    if (_scriptStep <= l.vocab.length) {
      final w = l.vocab[_scriptStep - 1];
      final prevAck = _scriptStep == 1 ? 'Great!' : 'Perfect!';
      return '$prevAck The ${_scriptStep == 1 ? 'first' : 'next'} word is "${w.word}". '
          'It means "${w.translation}" in $_targetName.\nSay "${w.word}".';
    }
    if (_scriptStep == l.vocab.length + 1) {
      return 'Excellent work! Our grammar focus is: ${l.grammarPoints.join(', ')}. '
          'You now know all the material of this lesson! $kLessonDoneMarker';
    }
    if (_scriptStep == l.vocab.length + 2) {
      return "We're now going to practice using the words and grammar you just learned. "
          "I'll only use the material from your lesson, and you should too. Ready? Just respond and we'll begin!";
    }
    if (_scriptStep < l.vocab.length + 8) {
      final w = l.vocab[(_scriptStep - 3) % l.vocab.length];
      return 'Great! Now, how would you say "${w.translation}" in $_targetName?';
    }
    return 'Fantastic! You completed the practice session. $kPracticeDoneMarker';
  }
}
