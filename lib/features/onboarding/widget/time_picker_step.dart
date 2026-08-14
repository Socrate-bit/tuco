import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:time_picker_spinner/time_picker_spinner.dart';

import '../../../core/theme/app_theme.dart';

/// "When do you want to practice?" page with a spinner time selector.
class TimePickerStep extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String initialTime; // 'HH:mm'
  final ValueChanged<String> onChanged;

  const TimePickerStep({
    super.key,
    required this.title,
    this.subtitle,
    required this.initialTime,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final parts = initialTime.split(':');
    final time = DateTime(2000, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.pageTitle),
          if (subtitle != null) ...[
            SizedBox(height: 8.h),
            Text(subtitle!, style: AppTextStyles.bodyGrey),
          ],
          Expanded(
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                width: double.infinity,
                child: TimePickerSpinner(
                  time: time,
                  minutesInterval: 5,
                  isForce2Digits: true,
                  alignment: Alignment.center,
                  hapticFeedback: true,
                  highlightedTextStyle: AppTextStyles.sectionTitle
                      .copyWith(fontSize: 34.sp, color: AppColors.titleDark),
                  normalTextStyle: AppTextStyles.sectionTitle.copyWith(
                      fontSize: 30.sp, color: AppColors.textLightGrey),
                  onTimeChange: (t) => onChanged(
                      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
