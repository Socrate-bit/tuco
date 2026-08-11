import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/service/haptics.dart';
import '../../../core/theme/app_theme.dart';
import '../../game/cubit/game_cubit.dart';
import '../../game/cubit/shop_cubit.dart';
import '../../game/service/heart_service.dart';
import '../../game/widget/shop_sheet.dart';
import '../../progression/cubit/stats_cubit.dart';

/// Home header: the pet on its meadow, name + hearts top-left, streak pill
/// top-right (swapped for the coin balance while the shop is open), Échange
/// bottom-left and the shop button bottom-right.
class HomeHeader extends StatelessWidget {
  final VoidCallback onStreakTap;
  final VoidCallback onExchangeTap;

  const HomeHeader({
    super.key,
    required this.onStreakTap,
    required this.onExchangeTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final streak = context.watch<StatsCubit>().state.currentStreak;
    final game = context.watch<GameCubit>().state;

    return SizedBox(
      height: 278.h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Meadow background, framed on the stump/lake band.
          Image.asset(
            'assets/images/game/pet_background.png',
            fit: BoxFit.cover,
            alignment: const Alignment(0, -0.45),
          ),
          // The pet, sitting above its stump — animation follows its mood.
          Align(
            alignment: const Alignment(0, 0.55),
            child: Image.asset(
              game.petAsset,
              width: 0.42.sw,
              height: 0.42.sw,
              fit: BoxFit.contain,
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pet name + hearts row.
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.petName,
                            style: AppTextStyles.button.copyWith(
                              fontSize: 26.sp,
                              shadows: const [
                                Shadow(
                                  color: Color(0x40000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              for (var i = 0; i < kHeartMax; i++)
                                Padding(
                                  padding: EdgeInsets.only(right: 4.w),
                                  child: Image.asset(
                                    i < game.hearts
                                        ? 'assets/images/game/heart_icon.png'
                                        : 'assets/images/game/heartempty_icon.png',
                                    width: 28.w,
                                    height: 28.w,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Streak count — live coin balance while the shop is open.
                      BlocBuilder<ShopCubit, bool>(
                        builder: (context, shopOpen) => shopOpen
                            ? _BareCounter(
                                onTap: () {},
                                icon: Icon(Icons.monetization_on_rounded,
                                    size: 26.r, color: AppColors.streakOrange),
                                value: '${game.coins}',
                              )
                            : _BareCounter(
                                onTap: onStreakTap,
                                icon: Image.asset(
                                    'assets/images/game/streak_icon.png',
                                    width: 28.w,
                                    height: 28.w),
                                value: '$streak',
                              ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      // "Échange" free-conversation button (now bottom-left).
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
                      const Spacer(),
                      // Shop button (bottom-right, where Échange used to be).
                      GestureDetector(
                        onTap: () {
                          Haptics.tap();
                          showShopSheet(context);
                        },
                        child: Image.asset(
                          'assets/images/game/shop_icon.png',
                          width: 52.w,
                          height: 52.w,
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

/// Bare icon + count (no card), with a soft shadow on the text so it stays
/// readable on the bright meadow.
class _BareCounter extends StatelessWidget {
  final Widget icon;
  final String value;
  final VoidCallback onTap;

  const _BareCounter({
    required this.icon,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Haptics.tap();
        onTap();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            SizedBox(width: 6.w),
            Text(
              value,
              style: AppTextStyles.button.copyWith(
                fontSize: 20.sp,
                shadows: const [
                  Shadow(
                    color: Color(0x40000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
