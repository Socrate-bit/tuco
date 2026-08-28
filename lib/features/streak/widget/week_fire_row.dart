import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../core/service/data_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../progression/cubit/stats_cubit.dart';

/// Monday→Sunday row of fire icons (orange = practiced, today highlighted).
class WeekFireRow extends StatelessWidget {
  const WeekFireRow({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatsCubit>().state;
    final today = DataRepository.today();
    final monday = DataRepository.addDays(today, 1 - today.weekday);
    final dayFormat = DateFormat.E('fr');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final day = DataRepository.addDays(monday, i);
        final practiced = stats.practicedOn(day);
        final isToday = day == today;
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
