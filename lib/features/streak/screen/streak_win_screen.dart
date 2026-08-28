import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widget/common_widgets.dart';
import '../../progression/cubit/stats_cubit.dart';
import '../widget/week_fire_row.dart';

/// Celebration screen after keeping the streak (big streak icon + week row).
class StreakWinScreen extends StatelessWidget {
  const StreakWinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final streak = context.watch<StatsCubit>().state.currentStreak;

    return Scaffold(
      backgroundColor: AppColors.card,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: const Alignment(0, -0.1),
            colors: [
              AppColors.streakCream,
              AppColors.card,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 3),
                Center(
                  child: Image.asset('assets/images/streaks.png',
                      width: 140.r, height: 140.r),
                ),
                SizedBox(height: 30.h),
                Text(
                  '$streak',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.display.copyWith(
                      color: AppColors.streakOrange, fontSize: 76.sp),
                ),
                Text(
                  l10n.streakDays,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.display.copyWith(
                      color: AppColors.streakOrange, fontSize: 30.sp),
                ),
                SizedBox(height: 24.h),
                Text(
                  l10n.streakHelper,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyGrey.copyWith(fontSize: 20.sp),
                ),
                SizedBox(height: 40.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 18.w, vertical: 20.h),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(color: AppColors.divider, width: 1.5),
                  ),
                  child: const WeekFireRow(),
                ),
                const Spacer(flex: 4),
                PrimaryButton(
                  label: l10n.understood,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
