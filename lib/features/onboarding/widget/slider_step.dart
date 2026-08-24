import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/service/haptics.dart';
import '../../../core/theme/app_theme.dart';

/// Slider question page (minutes per day / months to fluency).
/// [circular] draws the value inside a ring (fluency goal design);
/// otherwise the value is plain large text (daily minutes design).
class SliderStep extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String factChip; // small info chip under the subtitle
  final String valueLabel; // e.g. "15 minutes" or "12"
  final String? valueUnit; // unit under the value inside the ring
  final String? badge; // e.g. "Recommended", shown under the slider
  final bool circular;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;
  final Color accent;

  const SliderStep({
    super.key,
    required this.title,
    this.subtitle,
    required this.factChip,
    required this.valueLabel,
    this.valueUnit,
    this.badge,
    this.circular = false,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    required this.onChanged,
    this.accent = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.pageTitle),
          if (subtitle != null) ...[
            SizedBox(height: 8.h),
            Text(subtitle!, style: AppTextStyles.bodyGrey),
          ],
          SizedBox(height: 16.h),
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Text(factChip,
                  style: AppTextStyles.chip.copyWith(color: AppColors.navy)),
            ),
          ),
          SizedBox(height: 60.h),
          Center(
            child: circular
                ? Container(
                    width: 170.r,
                    height: 170.r,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: accent, width: 5),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(valueLabel,
                            style: AppTextStyles.sectionTitle
                                .copyWith(fontSize: 40.sp)),
                        if (valueUnit != null)
                          Text(valueUnit!, style: AppTextStyles.bodyGrey),
                      ],
                    ),
                  )
                : Text(valueLabel,
                    style:
                        AppTextStyles.sectionTitle.copyWith(fontSize: 40.sp)),
          ),
          SizedBox(height: 40.h),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: accent,
              inactiveTrackColor: AppColors.divider,
              thumbColor: Colors.white,
              overlayColor: accent.withValues(alpha: 0.12),
              trackHeight: 6.h,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: (v) {
                if (v.round() != value.round()) Haptics.select();
                onChanged(v);
              },
            ),
          ),
          if (badge != null) ...[
            SizedBox(height: 12.h),
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Text(badge!,
                    style: AppTextStyles.chip.copyWith(color: AppColors.navy)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
