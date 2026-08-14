import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/service/data_repository.dart';
import '../../../core/service/haptics.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widget/common_widgets.dart';
import '../../onboarding/cubit/onboarding_cubit.dart';
import 'privacy_policy_screen.dart';
import 'terms_conditions_screen.dart';

/// Settings page: account info (user type, user id) and legal pages.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // Copies the current Firebase UID to the clipboard.
  Future<void> _copyUserId(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await Clipboard.setData(ClipboardData(text: uid));
    messenger.showSnackBar(SnackBar(content: Text(l10n.settingsUserIdCopied)));
  }

  void _push(BuildContext context, Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  // Confirms then deletes all user data (account reset).
  Future<void> _deleteAccount(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final repository = context.read<DataRepository>();
    final onboarding = context.read<OnboardingCubit>();
    final navigator = Navigator.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.settingsDeleteAccountTitle),
        content: Text(l10n.settingsDeleteAccountBody),
        actions: [
          TextButton(
            onPressed: () {
              Haptics.tap();
              Navigator.pop(dialogContext, false);
            },
            child: Text(l10n.settingsDeleteAccountCancel),
          ),
          TextButton(
            onPressed: () {
              Haptics.tap();
              Navigator.pop(dialogContext, true);
            },
            child: Text(l10n.settingsDeleteAccountConfirm,
                style: const TextStyle(color: AppColors.scoreRed)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await repository.deleteAllUserData();
      // Drop the anonymous auth user and mint a fresh session so the
      // account starts from a clean uid.
      try {
        await FirebaseAuth.instance.currentUser?.delete();
      } catch (e) {
        debugPrint('[SettingsScreen] auth delete failed, signing out: $e');
        await FirebaseAuth.instance.signOut();
      }
      try {
        await FirebaseAuth.instance.signInAnonymously();
      } catch (e) {
        debugPrint('[SettingsScreen] anonymous re-sign-in failed: $e');
      }
      // Send the user back through onboarding (gate rebuilds at root).
      await onboarding.reset();
      navigator.popUntil((route) => route.isFirst);
      debugPrint('[SettingsScreen] Account data deleted');
      messenger.showSnackBar(
          SnackBar(content: Text(l10n.settingsDeleteAccountDone)));
    } catch (e) {
      debugPrint('[SettingsScreen] deleteAccount error: $e');
      messenger.showSnackBar(
          SnackBar(content: Text(l10n.settingsDeleteAccountError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BackCircleButton(),
              SizedBox(height: 16.h),
              Text(l10n.settingsTitle, style: AppTextStyles.pageTitle),
              SizedBox(height: 24.h),
              _SectionTitle(title: l10n.settingsAccount),
              _SettingsCard(children: [
                _LinkRow(
                  icon: Icons.card_membership_outlined,
                  label: l10n.settingsUserType,
                  value: l10n.settingsUserTypeFree,
                  onTap: () {},
                ),
                const _RowDivider(),
                _LinkRow(
                  icon: Icons.copy_outlined,
                  label: l10n.settingsCopyUserId,
                  onTap: () => _copyUserId(context),
                ),
              ]),
              SizedBox(height: 24.h),
              _SectionTitle(title: l10n.settingsAbout),
              _SettingsCard(children: [
                _LinkRow(
                  icon: Icons.privacy_tip_outlined,
                  label: l10n.settingsPrivacyPolicy,
                  onTap: () => _push(context, const PrivacyPolicyScreen()),
                ),
                const _RowDivider(),
                _LinkRow(
                  icon: Icons.description_outlined,
                  label: l10n.settingsTermsOfService,
                  onTap: () => _push(context, const TermsConditionsScreen()),
                ),
              ]),
              SizedBox(height: 24.h),
              _SectionTitle(title: l10n.settingsDangerZone),
              _SettingsCard(children: [
                _LinkRow(
                  icon: Icons.delete_forever_outlined,
                  label: l10n.settingsDeleteAccount,
                  color: AppColors.scoreRed,
                  onTap: () => _deleteAccount(context),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(title,
          style: AppTextStyles.small.copyWith(letterSpacing: 0.5)),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(children: children),
    );
  }
}

class _LinkRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Color? color;
  final VoidCallback onTap;

  const _LinkRow({
    required this.icon,
    required this.label,
    this.value,
    this.color,
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
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Row(
          children: [
            Icon(icon, size: 22.r, color: color ?? AppColors.textGrey),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.itemTitle
                      .copyWith(fontSize: 18.sp, color: color)),
            ),
            if (value != null) ...[
              Text(value!, style: AppTextStyles.itemSubtitle),
              SizedBox(width: 6.w),
            ],
            Icon(Icons.chevron_right_rounded,
                size: 22.r, color: AppColors.textLightGrey),
          ],
        ),
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 50.w),
      child: const Divider(height: 1, color: AppColors.divider),
    );
  }
}
