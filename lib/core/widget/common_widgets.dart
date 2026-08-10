import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../service/haptics.dart';
import '../theme/app_theme.dart';

/// Big blue rounded button with a "3D" darker bottom edge (Duolingo-like).
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color color;
  final Color shadowColor;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AppColors.primary,
    this.shadowColor = AppColors.primaryDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Haptics.tap();
        onPressed();
      },
      child: Container(
        width: double.infinity,
        height: 58.h,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(color: shadowColor, offset: Offset(0, 4.h)),
          ],
        ),
        alignment: Alignment.center,
        child: Text(label, style: AppTextStyles.button),
      ),
    );
  }
}

/// Blue text-only link button ("Peut-être plus tard", "Quitter l'appel"...).
class TextLinkButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color color;

  const TextLinkButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Haptics.tap();
        onPressed();
      },
      child: Padding(
        padding: EdgeInsets.all(12.r),
        child: Text(label,
            style: AppTextStyles.textLink.copyWith(color: color),
            textAlign: TextAlign.center),
      ),
    );
  }
}

/// Circular grey back button used on sub-page headers.
class BackCircleButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const BackCircleButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Haptics.tap();
        (onPressed ?? () => Navigator.of(context).pop())();
      },
      child: Container(
        width: 44.r,
        height: 44.r,
        decoration: const BoxDecoration(
          color: AppColors.background,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.chevron_left_rounded,
            color: AppColors.textGrey, size: 30.r),
      ),
    );
  }
}

/// Sub-page header: back button + centered navy title on white background.
class SubPageHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const SubPageHeader({super.key, required this.title});

  @override
  Size get preferredSize => Size.fromHeight(64.h);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.card,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: BackCircleButton(),
              ),
              Text(title, style: AppTextStyles.pageTitle),
            ],
          ),
        ),
      ),
    );
  }
}

/// Standard rounded white card used across list pages.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color color;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.color = AppColors.card,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: child,
    );
  }
}
