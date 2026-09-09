import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/model/app_language.dart';
import '../../../core/service/haptics.dart';
import '../../../core/theme/app_theme.dart';
import '../../profile/cubit/profile_cubit.dart';
import '../cubit/onboarding_cubit.dart';

/// Languages offered by the picker: the languages the app is translated into,
/// so picking one always re-localizes the interface. English first — it is the
/// default language until the user picks another.
List<String> get _pickable => AppLocalizations.supportedLocales
    .map((locale) => locale.languageCode)
    .where(AppLanguages.native.contains)
    .toList();

/// Applies [code] as the app language: the profile drives `MaterialApp.locale`
/// (instant re-localization) and the onboarding state keeps the choice so the
/// profile written at the end of the funnel does not reset it.
void _select(BuildContext context, String code) {
  final profile = context.read<ProfileCubit>();
  profile.update(profile.state.copyWith(nativeLanguage: code));
  context.read<OnboardingCubit>().setNativeLanguage(code);
}

/// Small rounded flag button (shows the active language) that opens the
/// language picker. Sits in the top-right of the onboarding header.
class LanguageFlagButton extends StatelessWidget {
  const LanguageFlagButton({super.key});

  @override
  Widget build(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    return GestureDetector(
      onTap: () {
        Haptics.tap();
        showLanguageSheet(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.divider),
        ),
        child: Text(AppLanguages.of(code).flag,
            style: TextStyle(fontSize: 24.sp)),
      ),
    );
  }
}

/// Bottom-sheet language picker. Selecting a language updates the profile,
/// which re-localizes the whole app reactively.
Future<void> showLanguageSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  final current = Localizations.localeOf(context).languageCode;

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.card,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r))),
    builder: (_) => SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
            SizedBox(height: 24.h),
            Text('🌍 ${l10n.nativeLanguage}', style: AppTextStyles.modalTitle),
            SizedBox(height: 26.h),
            for (final code in _pickable)
              Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _LanguageRow(
                  code: code,
                  selected: code == current,
                  onTap: () {
                    Haptics.select();
                    _select(context, code);
                    Navigator.pop(context);
                  },
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

/// One language row: flag, endonym and a check when it is the active language.
class _LanguageRow extends StatelessWidget {
  final String code;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageRow({
    required this.code,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final language = AppLanguages.of(code);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
            width: selected ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Text(language.flag, style: TextStyle(fontSize: 24.sp)),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(language.label,
                  style: AppTextStyles.chip.copyWith(fontSize: 19.sp)),
            ),
            if (selected)
              Icon(Icons.check_circle, size: 22.sp, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
