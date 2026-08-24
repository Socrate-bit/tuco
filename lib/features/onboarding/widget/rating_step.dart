import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';

/// "Give us a rating / made for people like you" social-proof page.
/// The Continue press on this page triggers the system review prompt.
class RatingStep extends StatelessWidget {
  const RatingStep({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.onboardingRatingTitle, style: AppTextStyles.pageTitle),
          SizedBox(height: 16.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('4.9', style: AppTextStyles.sectionTitle),
                    SizedBox(width: 8.w),
                    for (var i = 0; i < 5; i++)
                      Icon(Icons.star_rounded,
                          color: const Color(0xFFF7C948), size: 26.r),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(l10n.onboardingRatingCount, style: AppTextStyles.small),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          Center(
            child: Text(l10n.onboardingRatingMadeForYou,
                style: AppTextStyles.sectionTitle,
                textAlign: TextAlign.center),
          ),
          SizedBox(height: 16.h),
          Center(
            child: Image.asset('assets/images/game/pet_rest_animation.gif',
                width: 110.w),
          ),
          SizedBox(height: 4.h),
          Center(
            child: Text(l10n.onboardingRatingUsers, style: AppTextStyles.small),
          ),
          SizedBox(height: 24.h),
          _TestimonialCard(
            name: l10n.onboardingReview1Name,
            text: l10n.onboardingReview1Text,
          ),
          SizedBox(height: 12.h),
          _TestimonialCard(
            name: l10n.onboardingReview2Name,
            text: l10n.onboardingReview2Text,
          ),
        ],
      ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  final String name;
  final String text;

  const _TestimonialCard({required this.name, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < 5; i++)
                Icon(Icons.star_rounded,
                    color: const Color(0xFFF7C948), size: 20.r),
            ],
          ),
          SizedBox(height: 6.h),
          Text(name, style: AppTextStyles.itemTitle),
          SizedBox(height: 8.h),
          Text(text,
              style: AppTextStyles.bodyGrey, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
