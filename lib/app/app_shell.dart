import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/l10n/app_localizations.dart';
import '../core/service/haptics.dart';
import '../core/theme/app_theme.dart';
import '../features/home/screen/home_screen.dart';
import '../features/profile/screen/profile_screen.dart';
import '../features/progression/screen/progression_screen.dart';

/// Root shell with the 3-tab bottom navigation (Accueil / Progression / Profil).
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
      body: IndexedStack(
        index: _index,
        children: const [
          HomeScreen(),
          ProgressionScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.card,
          border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64.h,
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: l10n.tabHome,
                  selected: _index == 0,
                  onTap: () => _select(0),
                ),
                _NavItem(
                  icon: Icons.bar_chart_rounded,
                  label: l10n.tabProgress,
                  selected: _index == 1,
                  onTap: () => _select(1),
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: l10n.tabProfile,
                  selected: _index == 2,
                  onTap: () => _select(2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _select(int i) {
    Haptics.select();
    setState(() => _index = i);
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textLightGrey;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28.r),
            SizedBox(height: 2.h),
            Text(label,
                style: AppTextStyles.small.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
