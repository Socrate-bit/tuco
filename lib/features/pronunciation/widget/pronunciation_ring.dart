import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_theme.dart';

/// Maps a 0-100 pronunciation score to its tier color (red → yellow → green →
/// blue). Thresholds are intentionally simple and easy to tweak.
Color pronColor(double score) {
  if (score < 50) return AppColors.scoreRed;
  if (score < 75) return AppColors.scoreOrange;
  if (score < 90) return AppColors.scoreGreen;
  return AppColors.scoreBlue;
}

/// A circular progress ring whose sweep and color reflect a pronunciation
/// score. Small variant sits next to a chat bubble; large variant shows the
/// percentage in its center on the word detail screen.
class PronunciationRing extends StatelessWidget {
  final double score; // 0-100
  final double size;
  final double stroke;
  final bool showLabel;

  const PronunciationRing({
    super.key,
    required this.score,
    this.size = 24,
    this.stroke = 3,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = pronColor(score);
    final dimension = size.r;
    return SizedBox(
      width: dimension,
      height: dimension,
      child: CustomPaint(
        painter: _RingPainter(
          score: score,
          color: color,
          stroke: stroke.r,
        ),
        child: showLabel
            ? Center(
                child: Text(
                  '${score.round()}%',
                  style: AppTextStyles.itemTitle.copyWith(color: color),
                ),
              )
            : null,
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double score;
  final Color color;
  final double stroke;

  _RingPainter({
    required this.score,
    required this.color,
    required this.stroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = AppColors.divider;
    final progress = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;

    canvas.drawCircle(center, radius, track);
    final sweep = (score.clamp(0, 100) / 100) * 2 * math.pi;
    canvas.drawArc(rect, -math.pi / 2, sweep, false, progress);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.score != score || old.color != color || old.stroke != stroke;
}
