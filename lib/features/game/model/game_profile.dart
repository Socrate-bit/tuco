import 'package:equatable/equatable.dart';

import '../service/heart_service.dart';

/// Per-user gamification state (pet hearts + coins), persisted at
/// `users/{uid}/meta/game`. Adapted from Elevate's GameProfile.
class GameProfile extends Equatable {
  /// Spendable coin total (earned by completing lessons).
  final int coins;

  /// Persisted hearts (pet health): decays one per [kHeartDecayInterval],
  /// restored [kHeartRestorePerAction] per completed lesson, capped at
  /// [kHeartMax].
  final int hearts;

  /// Decay anchor for [hearts], epoch millis. Null on fresh docs.
  final int? heartsUpdatedAt;

  const GameProfile({
    this.coins = 0,
    this.hearts = kHeartMax,
    this.heartsUpdatedAt,
  });

  factory GameProfile.fromMap(Map<String, dynamic> data) => GameProfile(
        coins: (data['coins'] as int?) ?? 0,
        hearts: (data['hearts'] as int?) ?? kHeartMax,
        heartsUpdatedAt: data['heartsUpdatedAt'] as int?,
      );

  Map<String, dynamic> toMap() => {
        'coins': coins,
        'hearts': hearts,
        'heartsUpdatedAt': heartsUpdatedAt,
      };

  GameProfile copyWith({int? coins, int? hearts, int? heartsUpdatedAt}) =>
      GameProfile(
        coins: coins ?? this.coins,
        hearts: hearts ?? this.hearts,
        heartsUpdatedAt: heartsUpdatedAt ?? this.heartsUpdatedAt,
      );

  @override
  List<Object?> get props => [coins, hearts, heartsUpdatedAt];
}
