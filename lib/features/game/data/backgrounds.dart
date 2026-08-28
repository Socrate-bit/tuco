import 'package:equatable/equatable.dart';

import '../../../core/l10n/app_localizations.dart';

/// Id of the free backdrop every user starts with.
const kDefaultBackgroundId = 'forest_lake';

/// Backdrop forced behind the pet while it is hospitalized (0 hearts). Not sold
/// in the shop — it is a state, not a purchase.
const kHospitalBackgroundAsset = 'assets/backgrounds/hospital.png';

/// A home-header backdrop the pet sits on, bought with coins in the shop.
class PetBackground extends Equatable {
  final String id;

  /// Bundled asset path (all backdrops share the pet_background framing).
  final String asset;

  /// Coin price; `0` means free (owned from the start).
  final int price;

  const PetBackground({
    required this.id,
    required this.asset,
    required this.price,
  });

  bool get isFree => price == 0;

  @override
  List<Object?> get props => [id, asset, price];
}

/// Shop catalog, ordered cheapest → most expensive (drives display order).
const kPetBackgrounds = <PetBackground>[
  PetBackground(
      id: kDefaultBackgroundId,
      asset: 'assets/backgrounds/forest_lake.png',
      price: 0),
  PetBackground(
      id: 'desert_oasis',
      asset: 'assets/backgrounds/desert_oasis.png',
      price: 50),
  PetBackground(
      id: 'sweet_jungle',
      asset: 'assets/backgrounds/sweet_jungle.png',
      price: 100),
  PetBackground(
      id: 'meditation_garden',
      asset: 'assets/backgrounds/meditation_garden.png',
      price: 200),
  PetBackground(
      id: 'coastal_villa',
      asset: 'assets/backgrounds/coastal_villa.png',
      price: 350),
  PetBackground(
      id: 'luxury_spaceship',
      asset: 'assets/backgrounds/luxury_spaceship.png',
      price: 500),
];

/// Asset for [id], falling back to the free default for unknown ids.
String backgroundAssetFor(String id) => kPetBackgrounds
    .firstWhere((b) => b.id == id, orElse: () => kPetBackgrounds.first)
    .asset;

/// Localized display name for [id].
String backgroundLabel(AppLocalizations l10n, String id) => switch (id) {
      'desert_oasis' => l10n.bgDesertOasis,
      'sweet_jungle' => l10n.bgSweetJungle,
      'meditation_garden' => l10n.bgMeditationGarden,
      'coastal_villa' => l10n.bgCoastalVilla,
      'luxury_spaceship' => l10n.bgLuxurySpaceship,
      _ => l10n.bgForestLake,
    };
