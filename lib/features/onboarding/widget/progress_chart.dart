import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';

/// "Long-term results" card: Tuco curve vs traditional curve over 12 months.
class ProgressChart extends StatelessWidget {
  const ProgressChart({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        children: [
          Text(l10n.onboardingChartTitle, style: AppTextStyles.itemTitle),
          SizedBox(height: 16.h),
          SizedBox(
            height: 180.h,
            width: double.infinity,
            child: CustomPaint(
              painter: _CurvesPainter(
                tucoLabel: l10n.appName,
                traditionalLabel: l10n.onboardingChartTraditional,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.onboardingChartMonth1, style: AppTextStyles.small),
              Text(l10n.onboardingChartMonth12, style: AppTextStyles.small),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            l10n.onboardingChartCaption,
            style: AppTextStyles.small,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Paints the two progress curves with end dots and labels.
class _CurvesPainter extends CustomPainter {
  final String tucoLabel;
  final String traditionalLabel;

  _CurvesPainter({required this.tucoLabel, required this.traditionalLabel});

  Path _curve(Size size, double endFraction) {
    // Rising, flattening curve from bottom-left toward top-right.
    final start = Offset(0, size.height);
    final end = Offset(size.width, size.height * (1 - endFraction));
    return Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(size.width * 0.35, size.height * (1 - endFraction * 0.85),
          size.width * 0.6, end.dy + 6, end.dx, end.dy);
  }

  void _drawCurve(Canvas canvas, Size size, double endFraction, Color color,
      String label) {
    final path = _curve(size, endFraction);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, paint);
    final end = Offset(size.width, size.height * (1 - endFraction));
    canvas.drawCircle(end, 6, Paint()..color = color);
    final tp = TextPainter(
      text: TextSpan(
          text: label, style: AppTextStyles.small.copyWith(color: color)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(size.width - tp.width, end.dy - tp.height - 10));
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Dashed guide lines.
    final guide = Paint()
      ..color = AppColors.divider
      ..strokeWidth = 1;
    for (final f in [0.25, 0.5, 0.75]) {
      final y = size.height * f;
      for (double x = 0; x < size.width; x += 10) {
        canvas.drawLine(Offset(x, y), Offset(x + 5, y), guide);
      }
    }
    // Soft fill under the Tuco curve.
    final fill = _curve(size, 0.9)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(
        fill, Paint()..color = AppColors.primary.withValues(alpha: 0.08));
    _drawCurve(canvas, size, 0.55, AppColors.textLightGrey, traditionalLabel);
    _drawCurve(canvas, size, 0.9, AppColors.primary, tucoLabel);
  }

  @override
  bool shouldRepaint(covariant _CurvesPainter old) =>
      old.tucoLabel != tucoLabel || old.traditionalLabel != traditionalLabel;
}
