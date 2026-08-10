import 'package:equatable/equatable.dart';

/// User profile & settings.
class UserProfile extends Equatable {
  final String name;
  final String? email;
  final String nativeLanguage; // 'en', 'fr', ...
  final String targetLanguage; // 'es', ...
  final String level; // beginner | intermediate | advanced
  final List<String> interests;
  final int dailyGoalMinutes;
  final String? reminderTime; // 'HH:mm' or null when disabled
  final bool studyInNativeLanguage;

  const UserProfile({
    this.name = 'Lucas',
    this.email,
    this.nativeLanguage = 'en',
    this.targetLanguage = 'es',
    this.level = 'beginner',
    this.interests = const ['technology'],
    this.dailyGoalMinutes = 10,
    this.reminderTime,
    this.studyInNativeLanguage = true,
  });

  UserProfile copyWith({
    String? name,
    String? email,
    String? nativeLanguage,
    String? targetLanguage,
    String? level,
    List<String>? interests,
    int? dailyGoalMinutes,
    String? reminderTime,
    bool clearReminder = false,
    bool? studyInNativeLanguage,
  }) =>
      UserProfile(
        name: name ?? this.name,
        email: email ?? this.email,
        nativeLanguage: nativeLanguage ?? this.nativeLanguage,
        targetLanguage: targetLanguage ?? this.targetLanguage,
        level: level ?? this.level,
        interests: interests ?? this.interests,
        dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
        reminderTime: clearReminder ? null : (reminderTime ?? this.reminderTime),
        studyInNativeLanguage:
            studyInNativeLanguage ?? this.studyInNativeLanguage,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'nativeLanguage': nativeLanguage,
        'targetLanguage': targetLanguage,
        'level': level,
        'interests': interests,
        'dailyGoalMinutes': dailyGoalMinutes,
        'reminderTime': reminderTime,
        'studyInNativeLanguage': studyInNativeLanguage,
      };

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
        name: map['name'] as String? ?? 'Lucas',
        email: map['email'] as String?,
        nativeLanguage: map['nativeLanguage'] as String? ?? 'en',
        targetLanguage: map['targetLanguage'] as String? ?? 'es',
        level: map['level'] as String? ?? 'beginner',
        interests:
            (map['interests'] as List?)?.cast<String>() ?? const ['technology'],
        dailyGoalMinutes: map['dailyGoalMinutes'] as int? ?? 10,
        reminderTime: map['reminderTime'] as String?,
        studyInNativeLanguage: map['studyInNativeLanguage'] as bool? ?? true,
      );

  @override
  List<Object?> get props => [
        name,
        email,
        nativeLanguage,
        targetLanguage,
        level,
        interests,
        dailyGoalMinutes,
        reminderTime,
        studyInNativeLanguage,
      ];
}

/// Role of a chat message in a call.
enum MessageRole { ai, user, inspiration }

/// One message of a call transcript.
class ChatMessage extends Equatable {
  final MessageRole role;
  final String text;
  final String? translation; // lazily fetched translation
  final String? banner; // 'course' | 'courseDone' | 'practice' when banner row

  const ChatMessage({
    required this.role,
    required this.text,
    this.translation,
    this.banner,
  });

  ChatMessage copyWith({String? translation}) => ChatMessage(
        role: role,
        text: text,
        translation: translation ?? this.translation,
        banner: banner,
      );

  Map<String, dynamic> toMap() => {
        'role': role.name,
        'text': text,
        'translation': translation,
        'banner': banner,
      };

  factory ChatMessage.fromMap(Map<String, dynamic> map) => ChatMessage(
        role: MessageRole.values.byName(map['role'] as String? ?? 'ai'),
        text: map['text'] as String? ?? '',
        translation: map['translation'] as String?,
        banner: map['banner'] as String?,
      );

  @override
  List<Object?> get props => [role, text, translation, banner];
}

/// A completed (or aborted) call session.
class CallRecord extends Equatable {
  final String id;
  final String type; // 'lesson' | 'free'
  final String? lessonId;
  final String title;
  final DateTime startedAt;
  final int durationSeconds;
  final List<ChatMessage> transcript;
  final int newWordsCount;
  final bool completed;

  const CallRecord({
    required this.id,
    required this.type,
    this.lessonId,
    required this.title,
    required this.startedAt,
    required this.durationSeconds,
    required this.transcript,
    this.newWordsCount = 0,
    this.completed = false,
  });

  Map<String, dynamic> toMap() => {
        'type': type,
        'lessonId': lessonId,
        'title': title,
        'startedAt': startedAt.millisecondsSinceEpoch,
        'durationSeconds': durationSeconds,
        'transcript': transcript.map((m) => m.toMap()).toList(),
        'newWordsCount': newWordsCount,
        'completed': completed,
      };

  factory CallRecord.fromMap(String id, Map<String, dynamic> map) => CallRecord(
        id: id,
        type: map['type'] as String? ?? 'free',
        lessonId: map['lessonId'] as String?,
        title: map['title'] as String? ?? '',
        startedAt: DateTime.fromMillisecondsSinceEpoch(
            map['startedAt'] as int? ?? 0),
        durationSeconds: map['durationSeconds'] as int? ?? 0,
        transcript: (map['transcript'] as List?)
                ?.map((m) => ChatMessage.fromMap(Map<String, dynamic>.from(m)))
                .toList() ??
            const [],
        newWordsCount: map['newWordsCount'] as int? ?? 0,
        completed: map['completed'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [id, type, lessonId, title, startedAt];
}

/// One correction inside a grammar feedback item.
class Correction extends Equatable {
  final String wrong;
  final String right;
  final String explanation;

  const Correction({
    required this.wrong,
    required this.right,
    required this.explanation,
  });

  Map<String, dynamic> toMap() =>
      {'wrong': wrong, 'right': right, 'explanation': explanation};

  factory Correction.fromMap(Map<String, dynamic> map) => Correction(
        wrong: map['wrong'] as String? ?? '',
        right: map['right'] as String? ?? '',
        explanation: map['explanation'] as String? ?? '',
      );

  @override
  List<Object?> get props => [wrong, right, explanation];
}

/// A grammar or alternative feedback entry produced after a user sentence.
class FeedbackItem extends Equatable {
  final String id;
  final String type; // 'grammar' | 'alternative'
  final String? callId;
  final String? lessonId;
  final String? lessonTitle;
  final String originalText;
  final List<Correction> corrections;
  final int score; // 0-100
  final DateTime createdAt;

  const FeedbackItem({
    required this.id,
    required this.type,
    this.callId,
    this.lessonId,
    this.lessonTitle,
    required this.originalText,
    required this.corrections,
    required this.score,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'type': type,
        'callId': callId,
        'lessonId': lessonId,
        'lessonTitle': lessonTitle,
        'originalText': originalText,
        'corrections': corrections.map((c) => c.toMap()).toList(),
        'score': score,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory FeedbackItem.fromMap(String id, Map<String, dynamic> map) =>
      FeedbackItem(
        id: id,
        type: map['type'] as String? ?? 'grammar',
        callId: map['callId'] as String?,
        lessonId: map['lessonId'] as String?,
        lessonTitle: map['lessonTitle'] as String?,
        originalText: map['originalText'] as String? ?? '',
        corrections: (map['corrections'] as List?)
                ?.map((c) => Correction.fromMap(Map<String, dynamic>.from(c)))
                .toList() ??
            const [],
        score: map['score'] as int? ?? 0,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int? ?? 0),
      );

  @override
  List<Object?> get props => [id, type, originalText, score, createdAt];
}

/// A learned vocabulary word with metadata.
class LearnedWord extends Equatable {
  final String word;
  final String translation;
  final String? lessonId;
  final DateTime learnedAt;

  const LearnedWord({
    required this.word,
    required this.translation,
    this.lessonId,
    required this.learnedAt,
  });

  Map<String, dynamic> toMap() => {
        'word': word,
        'translation': translation,
        'lessonId': lessonId,
        'learnedAt': learnedAt.millisecondsSinceEpoch,
      };

  factory LearnedWord.fromMap(Map<String, dynamic> map) => LearnedWord(
        word: map['word'] as String? ?? '',
        translation: map['translation'] as String? ?? '',
        lessonId: map['lessonId'] as String?,
        learnedAt:
            DateTime.fromMillisecondsSinceEpoch(map['learnedAt'] as int? ?? 0),
      );

  @override
  List<Object?> get props => [word];
}

/// Aggregated practice for one day (streak + call time).
class PracticeDay extends Equatable {
  final String date; // 'yyyy-MM-dd'
  final int callSeconds;
  final int lessonsCompleted;

  const PracticeDay({
    required this.date,
    this.callSeconds = 0,
    this.lessonsCompleted = 0,
  });

  Map<String, dynamic> toMap() =>
      {'callSeconds': callSeconds, 'lessonsCompleted': lessonsCompleted};

  factory PracticeDay.fromMap(String date, Map<String, dynamic> map) =>
      PracticeDay(
        date: date,
        callSeconds: map['callSeconds'] as int? ?? 0,
        lessonsCompleted: map['lessonsCompleted'] as int? ?? 0,
      );

  @override
  List<Object?> get props => [date, callSeconds, lessonsCompleted];
}

/// Saved in-progress lesson session (for resume).
class SavedSession extends Equatable {
  final String lessonId;
  final List<ChatMessage> transcript;
  final String phase; // 'lesson' | 'practice'
  final int elapsedSeconds;

  const SavedSession({
    required this.lessonId,
    required this.transcript,
    required this.phase,
    required this.elapsedSeconds,
  });

  Map<String, dynamic> toMap() => {
        'transcript': transcript.map((m) => m.toMap()).toList(),
        'phase': phase,
        'elapsedSeconds': elapsedSeconds,
      };

  factory SavedSession.fromMap(String lessonId, Map<String, dynamic> map) =>
      SavedSession(
        lessonId: lessonId,
        transcript: (map['transcript'] as List?)
                ?.map((m) => ChatMessage.fromMap(Map<String, dynamic>.from(m)))
                .toList() ??
            const [],
        phase: map['phase'] as String? ?? 'lesson',
        elapsedSeconds: map['elapsedSeconds'] as int? ?? 0,
      );

  @override
  List<Object?> get props => [lessonId, transcript, phase, elapsedSeconds];
}
