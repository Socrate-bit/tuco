import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/service/analytics_service.dart';
import '../../../core/service/haptics.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widget/common_widgets.dart';
import '../cubit/game_cubit.dart';
import '../cubit/shop_cubit.dart';
import '../data/backgrounds.dart';

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

/// Half-height shop modal with a tab per customization category. The first tab
/// sells home-header backgrounds; the rest are coming-soon placeholders.
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

    // Rises exactly to the bottom of the home header (320.h) so the pet and
    // header pills stay visible above it. Its own ScaffoldMessenger keeps error
    // snack bars in front of the sheet instead of behind it, on the home
    // Scaffold.
    return SizedBox(
      height: MediaQuery.sizeOf(context).height - 320.h,
      child: ScaffoldMessenger(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: DefaultTabController(
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
                  // Category tabs — icon only, blue when selected, grey
                  // otherwise.
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
                      children: [
                        // Backgrounds are live; the others are stubs.
                        const _BackgroundGrid(),
                        for (final t in tabs.skip(1)) _ComingSoon(tab: t),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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

/// Background store: every catalog entry as a card, cheapest first. Owned
/// backdrops select on tap, locked ones ask to confirm the coin spend.
class _BackgroundGrid extends StatelessWidget {
  const _BackgroundGrid();

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameCubit>().state;

    return GridView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 0.72,
      ),
      itemCount: kPetBackgrounds.length,
      itemBuilder: (context, i) {
        final bg = kPetBackgrounds[i];
        return _BackgroundCard(
          background: bg,
          owned: game.owns(bg.id),
          selected: game.profile.selectedBackground == bg.id,
          onTap: () => _onTap(context, bg),
        );
      },
    );
  }

  Future<void> _onTap(BuildContext context, PetBackground bg) async {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<GameCubit>();
    final analytics = context.read<AnalyticsService>();
    final messenger = ScaffoldMessenger.of(context);

    // Already owned → just switch to it.
    if (cubit.state.owns(bg.id)) {
      if (cubit.state.profile.selectedBackground == bg.id) return;
      Haptics.select();
      analytics.track('background_selected', {'background': bg.id});
      await cubit.selectBackground(bg.id);
      return;
    }

    if (!cubit.state.canAfford(bg.price)) {
      Haptics.impact();
      messenger.showSnackBar(SnackBar(content: Text(l10n.shopNotEnoughCoins)));
      return;
    }

    final confirmed = await _confirmPurchase(context, bg);
    if (confirmed != true) return;

    final ok = await cubit.buyBackground(bg);
    if (!ok) {
      Haptics.impact();
      messenger.showSnackBar(SnackBar(content: Text(l10n.shopNotEnoughCoins)));
      return;
    }
    Haptics.success();
    analytics
        .track('background_purchased', {'background': bg.id, 'price': bg.price});
  }
}

/// Confirmation dialog before spending coins on a locked backdrop.
Future<bool?> _confirmPurchase(BuildContext context, PetBackground bg) {
  Haptics.tap();
  final l10n = AppLocalizations.of(context)!;
  return showDialog<bool>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Padding(
        padding: EdgeInsets.all(28.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Image.asset(
                bg.asset,
                height: 120.h,
                width: double.infinity,
                fit: BoxFit.cover,
                alignment: const Alignment(0, -0.45),
              ),
            ),
            SizedBox(height: 20.h),
            Text(l10n.shopBuyTitle,
                textAlign: TextAlign.center, style: AppTextStyles.modalTitle),
            SizedBox(height: 12.h),
            Text(l10n.shopBuyBody(bg.price),
                textAlign: TextAlign.center, style: AppTextStyles.bodyGrey),
            SizedBox(height: 26.h),
            PrimaryButton(
              label: l10n.shopBuyConfirm,
              onPressed: () => Navigator.pop(ctx, true),
            ),
            SizedBox(height: 10.h),
            TextLinkButton(
              label: l10n.shopCancel,
              onPressed: () => Navigator.pop(ctx, false),
            ),
          ],
        ),
      ),
    ),
  );
}

/// One backdrop in the store: preview, name, and a footer that reads either
/// "Selected", "Select" or its coin price.
class _BackgroundCard extends StatelessWidget {
  final PetBackground background;
  final bool owned;
  final bool selected;
  final VoidCallback onTap;

  const _BackgroundCard({
    required this.background,
    required this.owned,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
            width: 2.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Framed like the home header so the preview matches.
                    Image.asset(
                      background.asset,
                      fit: BoxFit.cover,
                      alignment: const Alignment(0, -0.45),
                    ),
                    // Locked backdrops are dimmed behind a lock badge.
                    if (!owned)
                      Container(
                        color: Colors.black26,
                        alignment: Alignment.center,
                        child: Icon(Icons.lock_rounded,
                            color: Colors.white, size: 28.r),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              backgroundLabel(l10n, background.id),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.itemTitle.copyWith(fontSize: 14.sp),
            ),
            SizedBox(height: 6.h),
            _CardFooter(
                background: background, owned: owned, selected: selected),
          ],
        ),
      ),
    );
  }
}

/// Status pill under a background card.
class _CardFooter extends StatelessWidget {
  final PetBackground background;
  final bool owned;
  final bool selected;

  const _CardFooter({
    required this.background,
    required this.owned,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = selected
        ? AppColors.green
        : owned
            ? AppColors.primary
            : AppColors.streakOrange;

    return Container(
      height: 30.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            selected
                ? Icons.check_circle_rounded
                : owned
                    ? Icons.brush_rounded
                    : Icons.monetization_on_rounded,
            size: 16.r,
            color: color,
          ),
          SizedBox(width: 5.w),
          Text(
            selected
                ? l10n.shopSelected
                : owned
                    ? l10n.shopSelect
                    : '${background.price}',
            style: AppTextStyles.small.copyWith(color: color, fontSize: 13.sp),
          ),
        ],
      ),
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
