import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/service/data_repository.dart';
import '../model/game_profile.dart';
import '../service/heart_service.dart';

/// Game state: the persisted profile plus the locally-settled heart count
/// (decay applied against the clock without waiting for a write).
class GameState extends Equatable {
  final GameProfile profile;
  final int hearts;

  const GameState({this.profile = const GameProfile(), this.hearts = kHeartMax});

  int get coins => profile.coins;

  /// Pet animation asset for the current mood.
  String get petAsset => HeartService.petAssetForHearts(hearts);

  @override
  List<Object?> get props => [profile, hearts];
}

/// Streams the game profile and ticks every minute so heart decay shows up
/// (and gets persisted) without any user action.
class GameCubit extends Cubit<GameState> {
  final DataRepository _repo;
  StreamSubscription? _sub;
  Timer? _ticker;

  GameCubit(this._repo) : super(const GameState()) {
    _sub = _repo.gameProfileStream().listen(
      (profile) => emit(GameState(profile: profile, hearts: _settled(profile))),
      onError: (e) => debugPrint('[GameCubit] stream error: $e'),
    );
    _ticker = Timer.periodic(const Duration(minutes: 1), (_) => _tick());
  }

  int _settled(GameProfile profile) => HeartService.settle(
        profile.hearts,
        profile.heartsUpdatedAt,
        DateTime.now().millisecondsSinceEpoch,
      ).hearts;

  void _tick() {
    final settled = _settled(state.profile);
    if (settled != state.hearts) {
      emit(GameState(profile: state.profile, hearts: settled));
      _repo.settleHearts();
    }
  }

  /// Awards a completed lesson (+coins, hearts restored). Optimistic: the
  /// Firestore stream confirms shortly after.
  Future<void> awardLessonCompletion() => _repo.awardLessonCompletion();

  @override
  Future<void> close() {
    _sub?.cancel();
    _ticker?.cancel();
    return super.close();
  }
}
