import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../core/l10n/app_localizations.dart';
import '../core/service/haptics.dart';
import '../core/theme/app_theme.dart';
import '../features/home/screen/home_screen.dart';
import '../features/profile/screen/profile_screen.dart';
import '../features/progression/screen/progression_screen.dart';

/// Root shell with the floating liquid-glass bottom navigation
/// (Accueil / Progression / Profil) — bar style ported from Elevate.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      // Content scrolls behind the floating glass bar.
      extendBody: true,
      body: IndexedStack(
        index: _index,
        children: const [
          HomeScreen(),
          ProgressionScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: 16.h, left: 24.w, right: 24.w),
        child: GlassTabBar.bottom(
          tabs: [
            GlassTab(
              thickness: 1,
              label: l10n.tabHome,
              icon: const Icon(Icons.home_rounded),
            ),
            GlassTab(
              label: l10n.tabProgress,
              icon: const Icon(Icons.bar_chart_rounded),
            ),
            GlassTab(
              label: l10n.tabProfile,
              icon: const Icon(Icons.person_rounded),
            ),
          ],
          selectedIndex: _index,
          onTabSelected: (i) {
            Haptics.select();
            setState(() => _index = i);
          },
          // Outer Padding owns the margins; let the bar fill the slot.
          horizontalPadding: 0,
          verticalPadding: 0,
          barHeight: 80.h,
          iconSize: 35.sp,
          labelFontSize: 11.sp,
          iconLabelSpacing: 1,
          selectedIconColor: AppColors.primary,
          unselectedIconColor: AppColors.textGrey,
          indicatorColor: AppColors.primaryLight,
          quality: GlassQuality.premium,
          interactionBehavior: GlassInteractionBehavior.full,
          settings: LiquidGlassSettings(
            glassColor: Colors.white.withValues(alpha: 0.8),
            thickness: 30,
            blur: 2,
            chromaticAberration: .01,
            lightAngle: GlassDefaults.lightAngle,
            lightIntensity: .5,
            ambientStrength: 0,
            refractiveIndex: 1.2,
            saturation: 1.2,
            specularSharpness: GlassSpecularSharpness.medium,
          ),
        ),
      ),
    );
  }
}
