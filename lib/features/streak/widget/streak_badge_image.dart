import 'package:flutter/material.dart';

/// Renders a streak-badge PNG, zoom-cropped by 15% (7.5% off each edge) to
/// remove the transparent padding baked into the source art. Unearned badges
/// are desaturated and dimmed to read as "locked".
class StreakBadgeImage extends StatelessWidget {
  final String asset;
  final double size;
  final bool earned;

  /// Fraction of the frame kept after the zoom-crop (0.85 = 15% cropped).
  static const double _keep = 0.85;

  const StreakBadgeImage({
    super.key,
    required this.asset,
    required this.size,
    this.earned = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget image = ClipRect(
      child: Transform.scale(
        scale: 1 / _keep,
        child: Image.asset(asset, fit: BoxFit.contain),
      ),
    );

    if (!earned) {
      // Greyscale (locked) treatment.
      const greyscale = <double>[
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0, 0, 0, 1, 0,
      ];
      image = Opacity(
        opacity: 0.4,
        child: ColorFiltered(
          colorFilter: const ColorFilter.matrix(greyscale),
          child: image,
        ),
      );
    }

    return SizedBox(width: size, height: size, child: image);
  }
}
