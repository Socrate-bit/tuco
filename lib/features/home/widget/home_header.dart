import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/service/haptics.dart';
import '../../../core/theme/app_theme.dart';
import '../../game/cubit/game_cubit.dart';
import '../../game/cubit/shop_cubit.dart';
import '../../game/screen/hospital_screen.dart';
import '../../game/service/heart_service.dart';
import '../../game/widget/shop_sheet.dart';
import '../../progression/cubit/stats_cubit.dart';

/// Home header: the pet on its meadow, name + hearts top-left, streak pill
/// top-right (swapped for the coin balance while the shop is open), Appeler
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
      height: 320.h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Backdrop chosen in the shop, framed on its stump/platform band.
          Image.asset(
            game.backgroundAsset,
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
                  // Out of hearts: the pet sits at the hospital until the
                  // discharge fee is paid.
                  if (game.inHospital) ...[
                    SizedBox(height: 14.h),
                    _HospitalBanner(fee: game.dischargeFee),
                  ],
                  const Spacer(),
                  Row(
                    children: [
                      // "Appeler" free-conversation call button (bottom-left).
                      GestureDetector(
                        onTap: () {
                          Haptics.impact();
                          onExchangeTap();
                        },
                        child: Container(
                          height: 48.h,
                          padding: EdgeInsets.symmetric(horizontal: 22.w),
                          // Same "3D" style as PrimaryButton: flat fill with a
                          // hard darker bottom edge.
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryDark,
                                offset: Offset(0, 4.h),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // White circular badge holding the call glyph.
                              Container(
                                width: 24.r,
                                height: 24.r,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.call_rounded,
                                    color: AppColors.primary, size: 16.r),
                              ),
                              SizedBox(width: 10.w),
                              Text(l10n.exchange, style: AppTextStyles.button),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Shop button (bottom-right, where the call button used to be).
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

/// Hospital call-to-action shown while the pet has no hearts left: what
/// happened, plus a button opening the discharge dialog with its coin cost
/// ("Free" when the purse is empty).
class _HospitalBanner extends StatelessWidget {
  final int fee;

  const _HospitalBanner({required this.fee});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: AppColors.whiteTranslucent,
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.local_hospital_rounded,
                    size: 18.r, color: AppColors.lessonRed),
                SizedBox(width: 6.w),
                Text(
                  l10n.hospitalBanner,
                  style: AppTextStyles.button.copyWith(
                    fontSize: 15.sp,
                    color: AppColors.titleDark,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          GestureDetector(
            onTap: () => showHospitalScreen(context),
            child: Container(
              height: 44.h,
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              // Same "3D" style as the Appeler button.
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(18.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDark,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.hospitalHeal, style: AppTextStyles.button),
                  SizedBox(width: 8.w),
                  Icon(Icons.monetization_on_rounded,
                      size: 20.r, color: Colors.white),
                  SizedBox(width: 4.w),
                  Text('$fee', style: AppTextStyles.button),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Icon + count inside a translucent pill card so it reads clearly on the
/// bright meadow.
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
      child: Container(
        height: 44.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: AppColors.whiteTranslucent,
          borderRadius: BorderRadius.circular(22.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            SizedBox(width: 6.w),
            Text(
              value,
              style: AppTextStyles.button.copyWith(
                fontSize: 20.sp,
                color: AppColors.titleDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
