import 'package:equatable/equatable.dart';

import '../../../core/l10n/app_localizations.dart';

/// A streak milestone badge: unlocked once the longest streak reaches
/// [requiredDays]. Each milestone has its own PNG art.
class StreakBadge extends Equatable {
  final String id;
  final int requiredDays;
  final String imageAsset;

  const StreakBadge({
    required this.id,
    required this.requiredDays,
    required this.imageAsset,
  });

  /// Localized display name of the badge.
  String name(AppLocalizations l10n) => switch (id) {
        'risen' => l10n.badgeRisen,
        'ignite' => l10n.badgeIgnite,
        'horizon' => l10n.badgeHorizon,
        'aurora' => l10n.badgeAurora,
        'celestial' => l10n.badgeCelestial,
        'nebula' => l10n.badgeNebula,
        _ => l10n.badgeEternal,
      };

  @override
  List<Object?> get props => [id, requiredDays, imageAsset];
}

/// All streak milestones, ordered by required days.
const streakBadges = [
  StreakBadge(
      id: 'risen',
      requiredDays: 1,
      imageAsset: 'assets/images/streak_badges/1.png'),
  StreakBadge(
      id: 'ignite',
      requiredDays: 3,
      imageAsset: 'assets/images/streak_badges/3.png'),
  StreakBadge(
      id: 'horizon',
      requiredDays: 7,
      imageAsset: 'assets/images/streak_badges/7.png'),
  StreakBadge(
      id: 'aurora',
      requiredDays: 14,
      imageAsset: 'assets/images/streak_badges/14.png'),
  StreakBadge(
      id: 'celestial',
      requiredDays: 30,
      imageAsset: 'assets/images/streak_badges/30.png'),
  StreakBadge(
      id: 'nebula',
      requiredDays: 100,
      imageAsset: 'assets/images/streak_badges/100.png'),
  StreakBadge(
      id: 'eternal',
      requiredDays: 365,
      imageAsset: 'assets/images/streak_badges/365.png'),
];
