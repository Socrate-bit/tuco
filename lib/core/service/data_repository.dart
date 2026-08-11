import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../features/game/model/game_profile.dart';
import '../../features/game/service/heart_service.dart';
import '../model/models.dart';

/// Central persistence layer. Uses Firestore streams when Firebase is
/// configured; falls back to an in-memory store so the app stays fully
/// functional (per-launch) before the Firebase project is wired.
class DataRepository {
  DataRepository({required bool useFirestore}) : _useFirestore = useFirestore;

  final bool _useFirestore;

  // ---- In-memory fallback state ----
  UserProfile _profile = const UserProfile();
  final List<CallRecord> _calls = [];
  final List<FeedbackItem> _feedback = [];
  final List<LearnedWord> _learned = [];
  final Map<String, PracticeDay> _practiceDays = {};
  final Set<String> _completedLessons = {};
  final Map<String, SavedSession> _sessions = {};

  final _profileCtrl = StreamController<UserProfile>.broadcast();
  final _callsCtrl = StreamController<List<CallRecord>>.broadcast();
  final _feedbackCtrl = StreamController<List<FeedbackItem>>.broadcast();
  final _learnedCtrl = StreamController<List<LearnedWord>>.broadcast();
  final _daysCtrl = StreamController<List<PracticeDay>>.broadcast();
  final _completedCtrl = StreamController<Set<String>>.broadcast();

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  DocumentReference<Map<String, dynamic>> get _userDoc =>
      FirebaseFirestore.instance.collection('users').doc(_uid);

  // ---------------- Profile ----------------

  Stream<UserProfile> profileStream() {
    if (_useFirestore) {
      return _userDoc.snapshots().map((snap) =>
          snap.data() == null ? const UserProfile() : UserProfile.fromMap(snap.data()!));
    }
    return _seeded(_profileCtrl, () => _profile);
  }

  Future<void> saveProfile(UserProfile profile) async {
    try {
      if (_useFirestore) {
        await _userDoc.set(profile.toMap(), SetOptions(merge: true));
      } else {
        _profile = profile;
        _profileCtrl.add(profile);
      }
      debugPrint('[DataRepository] Profile saved');
    } catch (e) {
      debugPrint('[DataRepository] saveProfile error: $e');
      rethrow;
    }
  }

  // ---------------- Calls ----------------

  Stream<List<CallRecord>> callsStream() {
    if (_useFirestore) {
      return _userDoc
          .collection('calls')
          .orderBy('startedAt', descending: true)
          .snapshots()
          .map((s) => s.docs.map((d) => CallRecord.fromMap(d.id, d.data())).toList());
    }
    return _seeded(_callsCtrl, () => _sortedCalls());
  }

  List<CallRecord> _sortedCalls() {
    final list = List<CallRecord>.from(_calls)
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return list;
  }

  Future<void> addCall(CallRecord call) async {
    try {
      if (_useFirestore) {
        await _userDoc.collection('calls').doc(call.id).set(call.toMap());
      } else {
        _calls.add(call);
        _callsCtrl.add(_sortedCalls());
      }
      debugPrint('[DataRepository] Call saved: ${call.title}');
    } catch (e) {
      debugPrint('[DataRepository] addCall error: $e');
    }
  }

  // ---------------- Feedback ----------------

  Stream<List<FeedbackItem>> feedbackStream() {
    if (_useFirestore) {
      return _userDoc
          .collection('feedback')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((s) =>
              s.docs.map((d) => FeedbackItem.fromMap(d.id, d.data())).toList());
    }
    return _seeded(_feedbackCtrl, () => List.from(_feedback.reversed));
  }

  Future<void> addFeedback(FeedbackItem item) async {
    try {
      if (_useFirestore) {
        await _userDoc.collection('feedback').doc(item.id).set(item.toMap());
      } else {
        _feedback.add(item);
        _feedbackCtrl.add(List.from(_feedback.reversed));
      }
      debugPrint('[DataRepository] Feedback saved (${item.type})');
    } catch (e) {
      debugPrint('[DataRepository] addFeedback error: $e');
    }
  }

  // ---------------- Vocabulary ----------------

  Stream<List<LearnedWord>> learnedWordsStream() {
    if (_useFirestore) {
      return _userDoc.collection('vocab').snapshots().map((s) => s.docs
          .map((d) => LearnedWord.fromMap(d.data()))
          .toList()
        ..sort((a, b) => b.learnedAt.compareTo(a.learnedAt)));
    }
    return _seeded(_learnedCtrl, () => List.from(_learned));
  }

  Future<void> addLearnedWords(List<LearnedWord> words) async {
    try {
      if (_useFirestore) {
        final batch = FirebaseFirestore.instance.batch();
        for (final w in words) {
          batch.set(_userDoc.collection('vocab').doc(w.word), w.toMap());
        }
        await batch.commit();
      } else {
        for (final w in words) {
          if (!_learned.any((e) => e.word == w.word)) _learned.add(w);
        }
        _learnedCtrl.add(List.from(_learned));
      }
      debugPrint('[DataRepository] ${words.length} words learned');
    } catch (e) {
      debugPrint('[DataRepository] addLearnedWords error: $e');
    }
  }

  // ---------------- Practice days (streak + call time) ----------------

  Stream<List<PracticeDay>> practiceDaysStream() {
    if (_useFirestore) {
      return _userDoc.collection('practiceDays').snapshots().map((s) =>
          s.docs.map((d) => PracticeDay.fromMap(d.id, d.data())).toList());
    }
    return _seeded(_daysCtrl, () => _practiceDays.values.toList());
  }

  static String dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> recordPractice(
      {required int addSeconds, bool lessonCompleted = false}) async {
    final key = dayKey(DateTime.now());
    try {
      if (_useFirestore) {
        await _userDoc.collection('practiceDays').doc(key).set({
          'callSeconds': FieldValue.increment(addSeconds),
          'lessonsCompleted': FieldValue.increment(lessonCompleted ? 1 : 0),
        }, SetOptions(merge: true));
      } else {
        final existing = _practiceDays[key] ?? PracticeDay(date: key);
        _practiceDays[key] = PracticeDay(
          date: key,
          callSeconds: existing.callSeconds + addSeconds,
          lessonsCompleted:
              existing.lessonsCompleted + (lessonCompleted ? 1 : 0),
        );
        _daysCtrl.add(_practiceDays.values.toList());
      }
      debugPrint('[DataRepository] Practice recorded: +${addSeconds}s');
    } catch (e) {
      debugPrint('[DataRepository] recordPractice error: $e');
    }
  }

  // ---------------- Lesson completion ----------------

  Stream<Set<String>> completedLessonsStream() {
    if (_useFirestore) {
      return _userDoc.snapshots().map((snap) =>
          ((snap.data()?['completedLessons'] as List?)?.cast<String>() ?? [])
              .toSet());
    }
    return _seeded(_completedCtrl, () => Set.from(_completedLessons));
  }

  Future<void> markLessonCompleted(String lessonId) async {
    try {
      if (_useFirestore) {
        await _userDoc.set({
          'completedLessons': FieldValue.arrayUnion([lessonId])
        }, SetOptions(merge: true));
      } else {
        _completedLessons.add(lessonId);
        _completedCtrl.add(Set.from(_completedLessons));
      }
      debugPrint('[DataRepository] Lesson completed: $lessonId');
    } catch (e) {
      debugPrint('[DataRepository] markLessonCompleted error: $e');
    }
  }

  // ---------------- Game profile (pet hearts + coins) ----------------

  GameProfile _game = const GameProfile();
  final _gameCtrl = StreamController<GameProfile>.broadcast();

  DocumentReference<Map<String, dynamic>> get _gameDoc =>
      _userDoc.collection('meta').doc('game');

  Stream<GameProfile> gameProfileStream() {
    if (_useFirestore) {
      return _gameDoc.snapshots().map((doc) => doc.data() == null
          ? const GameProfile()
          : GameProfile.fromMap(doc.data()!));
    }
    return _seeded(_gameCtrl, () => _game);
  }

  /// Awards a completed lesson: +[coins] and hearts restored
  /// (+[kHeartRestorePerAction], capped), re-basing the decay anchor.
  Future<void> awardLessonCompletion({int coins = kCoinsPerLesson}) async {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    try {
      if (_useFirestore) {
        await FirebaseFirestore.instance.runTransaction((tx) async {
          final snap = await tx.get(_gameDoc);
          final profile = snap.exists && snap.data() != null
              ? GameProfile.fromMap(snap.data()!)
              : const GameProfile();
          final hs =
              HeartService.restore(profile.hearts, profile.heartsUpdatedAt, nowMs);
          tx.set(
              _gameDoc,
              profile
                  .copyWith(
                      coins: profile.coins + coins,
                      hearts: hs.hearts,
                      heartsUpdatedAt: hs.anchorMs)
                  .toMap());
        });
      } else {
        final hs = HeartService.restore(_game.hearts, _game.heartsUpdatedAt, nowMs);
        _game = _game.copyWith(
            coins: _game.coins + coins,
            hearts: hs.hearts,
            heartsUpdatedAt: hs.anchorMs);
        _gameCtrl.add(_game);
      }
      debugPrint('[DataRepository] Lesson awarded: +$coins coins, hearts restored');
    } catch (e) {
      debugPrint('[DataRepository] awardLessonCompletion error: $e');
    }
  }

  /// Persists settled heart decay when whole steps have elapsed. Cheap to call
  /// periodically — writes only when the settled value differs.
  Future<void> settleHearts() async {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    try {
      if (_useFirestore) {
        await FirebaseFirestore.instance.runTransaction((tx) async {
          final snap = await tx.get(_gameDoc);
          if (!snap.exists || snap.data() == null) return;
          final profile = GameProfile.fromMap(snap.data()!);
          final hs =
              HeartService.settle(profile.hearts, profile.heartsUpdatedAt, nowMs);
          if (hs.hearts == profile.hearts &&
              hs.anchorMs == profile.heartsUpdatedAt) {
            return;
          }
          tx.set(
              _gameDoc,
              profile
                  .copyWith(hearts: hs.hearts, heartsUpdatedAt: hs.anchorMs)
                  .toMap());
        });
      } else {
        final hs = HeartService.settle(_game.hearts, _game.heartsUpdatedAt, nowMs);
        if (hs.hearts != _game.hearts || hs.anchorMs != _game.heartsUpdatedAt) {
          _game = _game.copyWith(hearts: hs.hearts, heartsUpdatedAt: hs.anchorMs);
          _gameCtrl.add(_game);
        }
      }
    } catch (e) {
      debugPrint('[DataRepository] settleHearts error: $e');
    }
  }

  // ---------------- Saved sessions (resume) ----------------

  Future<SavedSession?> getSavedSession(String lessonId) async {
    try {
      if (_useFirestore) {
        final snap = await _userDoc.collection('sessions').doc(lessonId).get();
        if (!snap.exists) return null;
        return SavedSession.fromMap(lessonId, snap.data()!);
      }
      return _sessions[lessonId];
    } catch (e) {
      debugPrint('[DataRepository] getSavedSession error: $e');
      return null;
    }
  }

  Future<void> saveSession(SavedSession session) async {
    try {
      if (_useFirestore) {
        await _userDoc
            .collection('sessions')
            .doc(session.lessonId)
            .set(session.toMap());
      } else {
        _sessions[session.lessonId] = session;
      }
    } catch (e) {
      debugPrint('[DataRepository] saveSession error: $e');
    }
  }

  Future<void> deleteSession(String lessonId) async {
    try {
      if (_useFirestore) {
        await _userDoc.collection('sessions').doc(lessonId).delete();
      } else {
        _sessions.remove(lessonId);
      }
    } catch (e) {
      debugPrint('[DataRepository] deleteSession error: $e');
    }
  }

  /// Broadcast stream that immediately emits the current value on listen.
  Stream<T> _seeded<T>(StreamController<T> ctrl, T Function() current) async* {
    yield current();
    yield* ctrl.stream;
  }
}
