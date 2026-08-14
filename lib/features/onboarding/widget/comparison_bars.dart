import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';

/// "2.7x faster" illustration: small grey bar vs tall orange bar with Tuco on top.
class ComparisonBars extends StatelessWidget {
  const ComparisonBars({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Bar(
          height: 90.h,
          color: AppColors.divider,
          valueLabel: '1x',
          valueStyle:
              AppTextStyles.itemTitle.copyWith(color: AppColors.textGrey),
          caption: l10n.onboardingCompareOthers,
        ),
        SizedBox(width: 24.w),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/game/pet_rest_animation.gif',
                width: 72.w),
            _Bar(
              height: 240.h,
              color: AppColors.primary,
              valueLabel: '2.7x',
              valueStyle:
                  AppTextStyles.sectionTitle.copyWith(color: Colors.white),
              caption: l10n.onboardingCompareTuco,
            ),
          ],
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  final double height;
  final Color color;
  final String valueLabel;
  final TextStyle valueStyle;
  final String caption;

  const _Bar({
    required this.height,
    required this.color,
    required this.valueLabel,
    required this.valueStyle,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 130.w,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Text(valueLabel, style: valueStyle),
        ),
        SizedBox(height: 10.h),
        Text(caption, style: AppTextStyles.body),
      ],
    );
  }
}
