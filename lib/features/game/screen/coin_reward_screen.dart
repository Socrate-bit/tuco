import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/service/haptics.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widget/common_widgets.dart';
import '../cubit/game_cubit.dart';

/// Celebration screen shown after a lesson: the coins just earned pop in and
/// count up, followed by the new balance.
class CoinRewardScreen extends StatefulWidget {
  final int coins;

  const CoinRewardScreen({super.key, required this.coins});

  @override
  State<CoinRewardScreen> createState() => _CoinRewardScreenState();
}

class _CoinRewardScreenState extends State<CoinRewardScreen> {
  @override
  void initState() {
    super.initState();
    Haptics.success();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final total = context.watch<GameCubit>().state.coins;

    return Scaffold(
      backgroundColor: AppColors.card,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: const Alignment(0, -0.1),
            colors: [AppColors.streakCream, AppColors.card],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 3),
                // Coin springs in.
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.elasticOut,
                  builder: (context, scale, child) =>
                      Transform.scale(scale: scale, child: child),
                  child: Icon(Icons.monetization_on_rounded,
                      size: 120.r, color: AppColors.streakOrange),
                ),
                SizedBox(height: 30.h),
                // Amount counts up from zero.
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: widget.coins),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOut,
                  builder: (context, value, _) => Text(
                    '+$value',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.display.copyWith(
                        color: AppColors.streakOrange, fontSize: 76.sp),
                  ),
                ),
                Text(
                  l10n.coinRewardTitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.display.copyWith(
                      color: AppColors.streakOrange, fontSize: 30.sp),
                ),
                SizedBox(height: 24.h),
                Text(
                  l10n.coinRewardSubtitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyGrey.copyWith(fontSize: 20.sp),
                ),
                SizedBox(height: 40.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(color: AppColors.divider, width: 1.5),
                  ),
                  child: Text(
                    l10n.coinRewardTotal(total),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.itemTitle.copyWith(fontSize: 20.sp),
                  ),
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
