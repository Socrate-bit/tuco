import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/service/analytics_service.dart';
import '../../../core/service/haptics.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widget/common_widgets.dart';
import '../../progression/cubit/stats_cubit.dart';
import '../cubit/game_cubit.dart';
import '../data/backgrounds.dart';
import '../service/heart_service.dart';

/// Opens the hospital gate. Returns true once the pet is discharged, false if
/// the user backs out — callers use it to decide whether to let a locked
/// lesson or free practice through.
Future<bool> showHospitalScreen(BuildContext context) async {
  Haptics.impact();
  final out = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (_) => const HospitalScreen(),
      fullscreenDialog: true,
    ),
  );
  return out ?? false;
}

/// Blocking page shown while the pet has no hearts left: lessons and free
/// practice stay locked until the discharge fee ([HeartService.dischargeFee],
/// free on an empty purse) is paid, which brings the pet back with
/// [kHeartsAfterDischarge] hearts. The hospital scene fills the screen with a
/// frosted glass panel floating over it.
class HospitalScreen extends StatelessWidget {
  const HospitalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameCubit>().state;

    return Scaffold(
      backgroundColor: AppColors.card,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // The hospital scene, dimmed just enough for the panel to read.
          Image.asset(
            kHospitalBackgroundAsset,
            fit: BoxFit.cover,
            alignment: const Alignment(0, -0.35),
          ),
          const ColoredBox(color: Color(0x33000000)),
          // The pet, sad in its bed, above the panel.
          Align(
            alignment: const Alignment(0, -0.28),
            child: Image.asset(
              game.petAsset,
              width: 0.42.sw,
              height: 0.42.sw,
              fit: BoxFit.contain,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Close button — leaves the pet hospitalized.
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.all(12.r),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        Haptics.tap();
                        Navigator.pop(context, false);
                      },
                      child: Container(
                        width: 40.r,
                        height: 40.r,
                        decoration: const BoxDecoration(
                          color: AppColors.whiteTranslucent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close_rounded,
                            size: 24.r, color: AppColors.titleDark),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                  child: const _HospitalPanel(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Frosted glass panel: the empty hearts, what is locked, the streak at stake,
/// the discharge cost and its call to action.
class _HospitalPanel extends StatelessWidget {
  const _HospitalPanel();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final game = context.watch<GameCubit>().state;
    final streak = context.watch<StatsCubit>().state.currentStreak;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: EdgeInsets.fromLTRB(24.w, 22.h, 24.w, 20.h),
          decoration: BoxDecoration(
            // Translucent white so the hospital stays visible through it.
            color: Colors.white.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(28.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Empty heart row — the reason everything is locked.
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < kHeartMax; i++)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3.w),
                      child: Image.asset(
                        'assets/images/game/heartempty_icon.png',
                        width: 26.w,
                        height: 26.w,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 14.h),
              Text(l10n.hospitalTitle,
                  textAlign: TextAlign.center, style: AppTextStyles.modalTitle),
              SizedBox(height: 10.h),
              Text(
                l10n.hospitalLockedBody,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyGrey.copyWith(color: AppColors.textDark),
              ),
              // The streak keeps running down while nothing can be practised —
              // worth calling out.
              if (streak > 0) ...[
                SizedBox(height: 14.h),
                _StreakWarning(streak: streak),
              ],
              SizedBox(height: 16.h),
              Text(
                game.dischargeFee == 0
                    ? l10n.hospitalBodyFree(kHeartsAfterDischarge)
                    : l10n.hospitalBody(game.dischargeFee, kHeartsAfterDischarge),
                textAlign: TextAlign.center,
                style: AppTextStyles.itemTitle,
              ),
              SizedBox(height: 20.h),
              PrimaryButton(
                label: l10n.hospitalConfirm,
                onPressed: () => _discharge(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Pays the fee and closes the gate. Only surfaces UI feedback on failure.
  Future<void> _discharge(BuildContext context) async {
    Haptics.tap();
    final cubit = context.read<GameCubit>();
    final analytics = context.read<AnalyticsService>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final l10n = AppLocalizations.of(context)!;
    final fee = cubit.state.dischargeFee;

    final ok = await cubit.leaveHospital();
    if (!ok) {
      Haptics.impact();
      messenger.showSnackBar(SnackBar(content: Text(l10n.hospitalError)));
      return;
    }
    Haptics.success();
    analytics.track('hospital_discharged', {'fee': fee});
    navigator.pop(true);
  }
}

/// Pill warning that the current streak is on the line while the pet is away.
class _StreakWarning extends StatelessWidget {
  final int streak;

  const _StreakWarning({required this.streak});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.streakCream,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/game/streak_icon.png',
              width: 22.w, height: 22.w),
          SizedBox(width: 8.w),
          Flexible(
            child: Text(
              l10n.hospitalStreakAtRisk(streak),
              style: AppTextStyles.small.copyWith(
                color: AppColors.streakOrange,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
