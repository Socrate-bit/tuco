import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/service/haptics.dart';
import '../../../core/theme/app_theme.dart';
import '../../progression/cubit/stats_cubit.dart';
import '../model/streak_badge.dart';
import '../screen/milestones_screen.dart';
import 'streak_badge_image.dart';
import 'week_fire_row.dart';

/// Streak card with the milestone system: current streak count, latest badge,
/// progress toward the next milestone and the week fire row.
/// Tapping opens the milestones screen.
class StreakMilestoneCard extends StatelessWidget {
  const StreakMilestoneCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final stats = context.watch<StatsCubit>().state;

    // Milestones are earned from the longest streak ever reached, so they
    // stay unlocked even after the current streak resets.
    StreakBadge? latest;
    StreakBadge? next;
    for (final b in streakBadges) {
      if (stats.longestStreak >= b.requiredDays) {
        latest = b;
      } else {
        next ??= b;
      }
    }
    final displayBadge = latest ?? streakBadges.first;
    final progress = next != null
        ? (stats.currentStreak / next.requiredDays).clamp(0.0, 1.0)
        : 1.0;

    return GestureDetector(
      onTap: () {
        Haptics.tap();
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const MilestonesScreen()));
      },
      child: Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: AppColors.streakCream,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset('assets/images/streaks.png',
                    width: 50.r, height: 50.r),
                SizedBox(width: 10.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${stats.currentStreak}',
                        style: AppTextStyles.sectionTitle
                            .copyWith(fontSize: 34.sp, height: 1)),
                    Text(l10n.dailyStreak, style: AppTextStyles.itemSubtitle),
                  ],
                ),
                const Spacer(),
                Column(
                  children: [
                    StreakBadgeImage(
                      asset: displayBadge.imageAsset,
                      size: 64.r,
                      earned: latest != null,
                    ),
                    Text(displayBadge.name(l10n),
                        style: AppTextStyles.itemSubtitle),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.h),
            if (next != null) ...[
              Row(
                children: [
                  Text(l10n.nextMilestone(next.requiredDays),
                      style: AppTextStyles.itemSubtitle),
                  const Spacer(),
                  Text('${stats.currentStreak} / ${next.requiredDays}',
                      style: AppTextStyles.itemSubtitle
                          .copyWith(fontWeight: FontWeight.w800)),
                ],
              ),
              SizedBox(height: 8.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8.h,
                  backgroundColor: AppColors.card,
                  color: AppColors.streakOrange,
                ),
              ),
            ] else
              Text(l10n.allMilestonesEarned, style: AppTextStyles.itemSubtitle),
            SizedBox(height: 22.h),
            const WeekFireRow(),
          ],
        ),
      ),
    );
  }
}
