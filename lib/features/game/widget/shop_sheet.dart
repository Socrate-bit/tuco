import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/service/haptics.dart';
import '../../../core/theme/app_theme.dart';
import '../cubit/shop_cubit.dart';

/// Opens the shop as a half-height modal sheet with no scrim, leaving the pet
/// and header pills visible. Flags the [ShopCubit] open/closed around its
/// lifetime so the home header swaps its streak pill for the coin balance.
/// (Ported from Elevate's shop sheet, restyled for Tuco.)
Future<void> showShopSheet(BuildContext context) async {
  final shop = context.read<ShopCubit>();
  shop.open();
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    // No scrim — the pet stays fully visible while shopping.
    barrierColor: Colors.transparent,
    builder: (_) => const _ShopSheet(),
  );
  shop.dismiss();
}

/// A shop tab: its icon asset plus the call-to-action shown in its body.
class _ShopTab {
  final String icon;
  final String cta;

  const _ShopTab({required this.icon, required this.cta});
}

/// Half-height shop modal with a tab per customization category. Each tab is a
/// coming-soon placeholder with its own call-to-action.
class _ShopSheet extends StatelessWidget {
  const _ShopSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const iconBase = 'assets/images/game/shop_tab';
    final tabs = <_ShopTab>[
      _ShopTab(icon: '$iconBase/image.png', cta: l10n.shopCtaBackground),
      _ShopTab(icon: '$iconBase/cap.png', cta: l10n.shopCtaHat),
      _ShopTab(icon: '$iconBase/safety-glasses.png', cta: l10n.shopCtaGlass),
      _ShopTab(icon: '$iconBase/scarf.png', cta: l10n.shopCtaScarf),
      _ShopTab(icon: '$iconBase/palette.png', cta: l10n.shopCtaColor),
    ];

    // Half the screen height so the pet and header pills stay visible.
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.55,
      child: DefaultTabController(
        length: tabs.length,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          child: Column(
            children: [
              // Grab handle.
              Padding(
                padding: EdgeInsets.only(top: 12.h, bottom: 4.h),
                child: Container(
                  width: 64.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              // Category tabs — icon only, blue when selected, grey otherwise.
              TabBar(
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textLightGrey,
                dividerColor: Colors.transparent,
                onTap: (_) => Haptics.select(),
                tabs: [for (final t in tabs) Tab(icon: _TabIcon(t.icon))],
              ),
              Expanded(
                child: TabBarView(
                  children: [for (final t in tabs) _ComingSoon(tab: t)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tab bar icon that tints itself with the current [IconTheme] colour, which
/// TabBar animates between grey (unselected) and blue (selected).
class _TabIcon extends StatelessWidget {
  final String asset;

  const _TabIcon(this.asset);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      width: 32.w,
      height: 32.w,
      color: IconTheme.of(context).color,
    );
  }
}

/// Placeholder body for a shop tab: the category icon, its call-to-action, and
/// a "coming soon" pill — vertically centered.
class _ComingSoon extends StatelessWidget {
  final _ShopTab tab;

  const _ComingSoon({required this.tab});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              tab.icon,
              width: 64.w,
              height: 64.w,
              color: AppColors.navy,
            ),
            SizedBox(height: 16.h),
            Text(
              tab.cta,
              textAlign: TextAlign.center,
              style: AppTextStyles.sectionTitle
                  .copyWith(color: AppColors.navy, fontSize: 20.sp),
            ),
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(21.r),
              ),
              child: Text(
                l10n.shopComingSoon,
                style: AppTextStyles.small
                    .copyWith(color: AppColors.primary, fontSize: 14.sp),
              ),
            ),
            SizedBox(height: 64.h),
          ],
        ),
      ),
    );
  }
}
