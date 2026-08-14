import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/service/haptics.dart';
import '../../../core/theme/app_theme.dart';

/// One selectable option of a survey step.
class SurveyOption {
  final String id;
  final String label;
  final Widget? icon; // emoji text or custom widget shown leading

  const SurveyOption({required this.id, required this.label, this.icon});
}

/// Single- or multi-choice question page: title, subtitle, option cards.
class SurveyStep extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<SurveyOption> options;
  final Set<String> selected;
  final ValueChanged<String> onTap;

  const SurveyStep({
    super.key,
    required this.title,
    this.subtitle,
    required this.options,
    required this.selected,
    required this.onTap,
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
          SizedBox(height: 24.h),
          for (final option in options) ...[
            _OptionCard(
              option: option,
              isSelected: selected.contains(option.id),
              onTap: () {
                Haptics.select();
                onTap(option.id);
              },
            ),
            SizedBox(height: 12.h),
          ],
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final SurveyOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionCard(
      {required this.option, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.card,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            if (option.icon != null) ...[
              option.icon!,
              SizedBox(width: 14.w),
            ],
            Expanded(child: Text(option.label, style: AppTextStyles.body)),
          ],
        ),
      ),
    );
  }
}
