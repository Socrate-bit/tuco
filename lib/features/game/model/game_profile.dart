import 'package:equatable/equatable.dart';

import '../data/backgrounds.dart';
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

  /// Ids of paid backdrops bought in the shop. The free default is implicit.
  final List<String> ownedBackgrounds;

  /// Id of the backdrop currently shown behind the pet on the home header.
  final String selectedBackground;

  const GameProfile({
    this.coins = 0,
    this.hearts = kHeartMax,
    this.heartsUpdatedAt,
    this.ownedBackgrounds = const [],
    this.selectedBackground = kDefaultBackgroundId,
  });

  /// True when [id] is free or already bought.
  bool ownsBackground(String id) =>
      id == kDefaultBackgroundId || ownedBackgrounds.contains(id);

  factory GameProfile.fromMap(Map<String, dynamic> data) => GameProfile(
        coins: (data['coins'] as int?) ?? 0,
        hearts: (data['hearts'] as int?) ?? kHeartMax,
        heartsUpdatedAt: data['heartsUpdatedAt'] as int?,
        ownedBackgrounds:
            (data['ownedBackgrounds'] as List?)?.cast<String>() ?? const [],
        selectedBackground:
            (data['selectedBackground'] as String?) ?? kDefaultBackgroundId,
      );

  Map<String, dynamic> toMap() => {
        'coins': coins,
        'hearts': hearts,
        'heartsUpdatedAt': heartsUpdatedAt,
        'ownedBackgrounds': ownedBackgrounds,
        'selectedBackground': selectedBackground,
      };

  GameProfile copyWith({
    int? coins,
    int? hearts,
    int? heartsUpdatedAt,
    List<String>? ownedBackgrounds,
    String? selectedBackground,
  }) =>
      GameProfile(
        coins: coins ?? this.coins,
        hearts: hearts ?? this.hearts,
        heartsUpdatedAt: heartsUpdatedAt ?? this.heartsUpdatedAt,
        ownedBackgrounds: ownedBackgrounds ?? this.ownedBackgrounds,
        selectedBackground: selectedBackground ?? this.selectedBackground,
      );

  @override
  List<Object?> get props =>
      [coins, hearts, heartsUpdatedAt, ownedBackgrounds, selectedBackground];
}
