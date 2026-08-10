import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/service/haptics.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widget/common_widgets.dart';
import '../../progression/cubit/stats_cubit.dart';

/// "Série" page: streak header, month stats and practice calendar.
class StreakScreen extends StatefulWidget {
  const StreakScreen({super.key});

  @override
  State<StreakScreen> createState() => _StreakScreenState();
}

class _StreakScreenState extends State<StreakScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final stats = context.watch<StatsCubit>().state;
    final monthFormat = DateFormat.yMMMM('fr');
    final now = DateTime.now();
    final isCurrentMonth = _month.year == now.year && _month.month == now.month;

    return Scaffold(
      backgroundColor: AppColors.card,
      body: Column(
        children: [
          // Cream header with big fire + count.
          Container(
            width: double.infinity,
            color: AppColors.streakCream,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 34.h),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Colors.white, shape: BoxShape.circle),
                            child: const BackCircleButton(),
                          ),
                        ),
                        Text(l10n.streakTitle,
                            style: AppTextStyles.pageTitle
                                .copyWith(color: AppColors.textDark)),
                      ],
                    ),
                    SizedBox(height: 22.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('🔥', style: TextStyle(fontSize: 86.sp)),
                        SizedBox(width: 18.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${stats.currentStreak}',
                              style: AppTextStyles.display.copyWith(
                                  color: AppColors.streakOrange,
                                  fontSize: 64.sp,
                                  height: 1),
                            ),
                            Text(
                              l10n.streakDays,
                              style: AppTextStyles.display.copyWith(
                                  color: AppColors.streakOrange,
                                  fontSize: 27.sp),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 20.h),
              children: [
                // Month selector.
                Row(
                  children: [
                    Text(monthFormat.format(_month),
                        style: AppTextStyles.sectionTitle
                            .copyWith(color: AppColors.navy)),
                    const Spacer(),
                    _MonthChevron(
                      icon: Icons.chevron_left_rounded,
                      enabled: true,
                      onTap: () => setState(() =>
                          _month = DateTime(_month.year, _month.month - 1)),
                    ),
                    SizedBox(width: 14.w),
                    _MonthChevron(
                      icon: Icons.chevron_right_rounded,
                      enabled: !isCurrentMonth,
                      onTap: () => setState(() =>
                          _month = DateTime(_month.year, _month.month + 1)),
                    ),
                  ],
                ),
                SizedBox(height: 18.h),
                // Longest streak / month training stats card.
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: AppColors.divider, width: 1.5),
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: _StreakStat(
                            emoji: '🔥',
                            label: l10n.longestStreak,
                            value: '${stats.longestStreak}',
                          ),
                        ),
                        const VerticalDivider(
                            color: AppColors.divider, thickness: 1.5),
                        Expanded(
                          child: _StreakStat(
                            emoji: '✅',
                            label: l10n.monthTraining,
                            value: '${stats.trainingsInMonth(_month)}',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 18.h),
                _MonthCalendar(month: _month, stats: stats),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 10.h),
              child: PrimaryButton(
                label: l10n.continueLearning,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthChevron extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _MonthChevron({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled
          ? () {
              Haptics.select();
              onTap();
            }
          : null,
      child: Icon(icon,
          size: 30.r,
          color: enabled ? AppColors.textGrey : AppColors.divider),
    );
  }
}

class _StreakStat extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;

  const _StreakStat({
    required this.emoji,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: TextStyle(fontSize: 30.sp)),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.itemSubtitle.copyWith(fontSize: 15.sp)),
              SizedBox(height: 2.h),
              Text(value,
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 22.sp)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Calendar grid with practiced-day highlights.
class _MonthCalendar extends StatelessWidget {
  final DateTime month;
  final StatsState stats;

  const _MonthCalendar({required this.month, required this.stats});

  @override
  Widget build(BuildContext context) {
    final dayFormat = DateFormat.E('fr');
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingEmpty = firstDay.weekday - 1; // Monday-first grid
    final now = DateTime.now();

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.divider, width: 1.5),
      ),
      child: Column(
        children: [
          // Weekday labels row (lun. → dim.).
          Row(
            children: List.generate(7, (i) {
              final day = DateTime(2024, 1, 1 + i); // a Monday
              return Expanded(
                child: Center(
                  child: Text(dayFormat.format(day),
                      style: AppTextStyles.small.copyWith(
                          fontSize: 16.sp, color: AppColors.textGrey)),
                ),
              );
            }),
          ),
          SizedBox(height: 10.h),
          for (var week = 0;
              week * 7 < leadingEmpty + daysInMonth;
              week++) ...[
            Row(
              children: List.generate(7, (dow) {
                final dayNum = week * 7 + dow - leadingEmpty + 1;
                if (dayNum < 1 || dayNum > daysInMonth) {
                  return const Expanded(child: SizedBox());
                }
                final date = DateTime(month.year, month.month, dayNum);
                final practiced = stats.practicedOn(date);
                final isToday = date.year == now.year &&
                    date.month == now.month &&
                    date.day == now.day;
                return Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 40.r,
                        height: 40.r,
                        decoration: practiced
                            ? const BoxDecoration(
                                color: AppColors.streakCream,
                                shape: BoxShape.circle)
                            : null,
                        child: Center(
                          child: Text(
                            '$dayNum',
                            style: AppTextStyles.chip.copyWith(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: practiced
                                  ? AppColors.streakOrange
                                  : AppColors.textDark,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 8.h,
                        child: isToday
                            ? Icon(Icons.circle,
                                size: 5.r,
                                color: practiced
                                    ? AppColors.streakOrange
                                    : AppColors.textGrey)
                            : null,
                      ),
                    ],
                  ),
                );
              }),
            ),
            SizedBox(height: 6.h),
          ],
        ],
      ),
    );
  }
}
