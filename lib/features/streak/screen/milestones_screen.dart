import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widget/common_widgets.dart';
import '../../progression/cubit/stats_cubit.dart';
import '../model/streak_badge.dart';
import '../widget/streak_badge_image.dart';

/// All streak milestones with their custom badge art. A badge is earned once
/// the longest streak reaches its required days.
class MilestonesScreen extends StatelessWidget {
  const MilestonesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final stats = context.watch<StatsCubit>().state;
    final earnedCount = streakBadges
        .where((b) => stats.longestStreak >= b.requiredDays)
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
              child: const BackCircleButton(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.milestonesTitle, style: AppTextStyles.pageTitle),
                    SizedBox(height: 16.h),
                    // Overall progress toward earning every milestone.
                    AppCard(
                      padding: EdgeInsets.all(16.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              l10n.milestonesEarnedCount(
                                  earnedCount, streakBadges.length),
                              style: AppTextStyles.itemTitle),
                          SizedBox(height: 10.h),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4.r),
                            child: LinearProgressIndicator(
                              value: earnedCount / streakBadges.length,
                              minHeight: 8.h,
                              backgroundColor: AppColors.background,
                              color: AppColors.streakOrange,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 16.h,
                        crossAxisSpacing: 16.w,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: streakBadges.length,
                      itemBuilder: (_, i) => _BadgeCell(
                        badge: streakBadges[i],
                        earned: stats.longestStreak >=
                            streakBadges[i].requiredDays,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeCell extends StatelessWidget {
  final StreakBadge badge;
  final bool earned;

  const _BadgeCell({required this.badge, required this.earned});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreakBadgeImage(
            asset: badge.imageAsset, size: 72.r, earned: earned),
        SizedBox(height: 8.h),
        Text(badge.name(l10n),
            style: AppTextStyles.itemSubtitle.copyWith(
                fontWeight: FontWeight.w800,
                color: earned ? AppColors.navy : AppColors.textGrey),
            textAlign: TextAlign.center),
        SizedBox(height: 2.h),
        Text(l10n.milestoneDays(badge.requiredDays),
            style: AppTextStyles.small, textAlign: TextAlign.center),
      ],
    );
  }
}
