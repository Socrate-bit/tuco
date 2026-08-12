import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../progression/cubit/stats_cubit.dart';

/// Monday→Sunday row of fire icons (orange = practiced, today highlighted).
class WeekFireRow extends StatelessWidget {
  const WeekFireRow({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatsCubit>().state;
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final dayFormat = DateFormat.E('fr');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final day = monday.add(Duration(days: i));
        final practiced = stats.practicedOn(day);
        final isToday = day.day == now.day && day.month == now.month;
        return Column(
          children: [
            Text(
              dayFormat.format(day),
              style: AppTextStyles.small.copyWith(
                fontSize: 17.sp,
                fontWeight: FontWeight.w800,
                color: isToday && practiced
                    ? AppColors.streakOrange
                    : AppColors.textDark,
              ),
            ),
            SizedBox(height: 10.h),
            practiced
                ? Image.asset('assets/images/streaks.png',
                    width: 34.r, height: 34.r)
                : Image.asset('assets/images/streaks.png',
                    width: 34.r,
                    height: 34.r,
                    color: AppColors.divider,
                    colorBlendMode: BlendMode.srcIn),
          ],
        );
      }),
    );
  }
}
