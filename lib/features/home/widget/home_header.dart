import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/service/haptics.dart';
import '../../../core/theme/app_theme.dart';
import '../../progression/cubit/stats_cubit.dart';

/// Fixed dark header with the robot tutor, language pill, streak pill and
/// the "Échange" (free conversation) button.
class HomeHeader extends StatelessWidget {
  final VoidCallback onStreakTap;
  final VoidCallback onExchangeTap;
  final VoidCallback onLanguageTap;

  const HomeHeader({
    super.key,
    required this.onStreakTap,
    required this.onExchangeTap,
    required this.onLanguageTap,
  });

  static double height(BuildContext context) =>
      278.h + MediaQuery.of(context).padding.top * 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final streak = context.watch<StatsCubit>().state.currentStreak;

    return SizedBox(
      height: 278.h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Radial navy gradient behind/around the robot image.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, 0.55),
                radius: 1.15,
                colors: [AppColors.headerCenter, AppColors.headerEdge],
              ),
            ),
          ),
          // Robot image anchored to the bottom, full width.
          Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset(
              'assets/images/robot_header.png',
              width: 1.sw,
              fit: BoxFit.fitWidth,
            ),
          ),
          // Overlaid controls.
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _HeaderPill(
                        onTap: onLanguageTap,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('🇪🇸', style: TextStyle(fontSize: 20.sp)),
                            SizedBox(width: 8.w),
                            Text('ES',
                                style: AppTextStyles.button
                                    .copyWith(fontSize: 17.sp)),
                          ],
                        ),
                      ),
                      _HeaderPill(
                        onTap: onStreakTap,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('🔥', style: TextStyle(fontSize: 18.sp)),
                            SizedBox(width: 6.w),
                            Text('$streak',
                                style: AppTextStyles.button
                                    .copyWith(fontSize: 17.sp)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // "Échange" free-conversation button.
                      GestureDetector(
                        onTap: () {
                          Haptics.impact();
                          onExchangeTap();
                        },
                        child: Container(
                          height: 52.h,
                          padding: EdgeInsets.symmetric(horizontal: 22.w),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(26.r),
                            boxShadow: [
                              BoxShadow(
                                  color: AppColors.primaryDark,
                                  offset: Offset(0, 3.h)),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.videocam_rounded,
                                  color: Colors.white, size: 24.r),
                              SizedBox(width: 10.w),
                              Text(l10n.exchange, style: AppTextStyles.button),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Translucent white pill used on the dark header.
class _HeaderPill extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _HeaderPill({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Haptics.tap();
        onTap();
      },
      child: Container(
        height: 44.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColors.whiteTranslucent,
          borderRadius: BorderRadius.circular(22.r),
        ),
        child: Center(child: child),
      ),
    );
  }
}
