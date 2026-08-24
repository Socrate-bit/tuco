import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/model/app_language.dart';
import '../../../core/service/haptics.dart';
import '../../../core/theme/app_theme.dart';
import '../../settings/screen/settings_screen.dart';
import '../cubit/profile_cubit.dart';
import '../service/reminder_service.dart';
import '../widget/picker_sheet.dart';

/// Profil tab: header, native-language toggle and settings rows.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  /// Picker options for a list of language codes.
  static List<PickerOption> _languageOptions(List<String> codes) => [
        for (final code in codes)
          PickerOption(
              value: code,
              label: AppLanguages.of(code).label,
              emoji: AppLanguages.of(code).flag),
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profile = context.watch<ProfileCubit>().state;
    final cubit = context.read<ProfileCubit>();

    String levelLabel(String level) => switch (level) {
          'beginner' => l10n.levelBeginner,
          'intermediate' => l10n.levelIntermediate,
          _ => l10n.levelAdvanced,
        };

    String interestLabel(String id) => switch (id) {
          'technology' => l10n.interestTechnology,
          'travel' => l10n.interestTravel,
          'cooking' => l10n.interestCooking,
          'sports' => l10n.interestSports,
          'music' => l10n.interestMusic,
          'movies' => l10n.interestMovies,
          'art' => l10n.interestArt,
          _ => l10n.interestBusiness,
        };

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          children: [
            // ---- Header: avatar + name + email + gear ----
            Container(
              color: AppColors.card,
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 34.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 96.r,
                        height: 96.r,
                        decoration: const BoxDecoration(
                            color: AppColors.primary, shape: BoxShape.circle),
                        child: Center(
                          child: Text(
                            profile.name.isEmpty
                                ? '?'
                                : profile.name[0].toUpperCase(),
                            style: AppTextStyles.display.copyWith(
                                color: Colors.white, fontSize: 46.sp),
                          ),
                        ),
                      ),
                      Positioned(
                        right: -4.r,
                        bottom: -4.r,
                        child: Container(
                          width: 36.r,
                          height: 36.r,
                          decoration: const BoxDecoration(
                              color: AppColors.primaryLight,
                              shape: BoxShape.circle),
                          child: Icon(Icons.add_rounded,
                              color: AppColors.primary, size: 22.r),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 20.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10.h),
                        GestureDetector(
                          onTap: () => _editName(context, profile.name),
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(profile.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.pageTitle
                                        .copyWith(fontSize: 30.sp)),
                              ),
                              SizedBox(width: 6.w),
                              Icon(Icons.chevron_right_rounded,
                                  color: AppColors.navy, size: 28.r),
                            ],
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          profile.email ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.itemSubtitle
                              .copyWith(fontSize: 18.sp),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Haptics.tap();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SettingsScreen()));
                    },
                    child: Icon(Icons.settings_rounded,
                        color: AppColors.textGrey, size: 32.r),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // ---- Settings rows ----
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  color: AppColors.card,
                  child: Column(
                    children: [
                      _SettingsRow(
                        emoji: '🎯',
                        label: l10n.learningLanguage,
                        value: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(AppLanguages.of(profile.targetLanguage).flag,
                                style: TextStyle(fontSize: 18.sp)),
                            SizedBox(width: 6.w),
                            Flexible(
                              child: Text(
                                  AppLanguages.labelOf(profile.targetLanguage),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.itemSubtitle
                                      .copyWith(fontSize: 19.sp)),
                            ),
                          ],
                        ),
                        onTap: () async {
                          final result = await showPickerSheet(
                            context,
                            emoji: '🎯',
                            title: l10n.learningLanguage,
                            options: _languageOptions(AppLanguages.learnable),
                            selected: [profile.targetLanguage],
                          );
                          if (result != null && result.isNotEmpty) {
                            cubit.update(
                                profile.copyWith(nativeLanguage: result.first));
                          }
                        },
                      ),
                      _divider(),
                      _SettingsRow(
                        emoji: AppLanguages.of(profile.targetLanguage).flag,
                        label: l10n.languageLevel,
                        value: Text(levelLabel(profile.level),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.itemSubtitle
                                .copyWith(fontSize: 19.sp)),
                        onTap: () async {
                          final result = await showPickerSheet(
                            context,
                            emoji: AppLanguages.of(profile.targetLanguage).flag,
                            title: l10n.languageLevel,
                            options: [
                              PickerOption(
                                  value: 'beginner',
                                  label: l10n.levelBeginner),
                              PickerOption(
                                  value: 'intermediate',
                                  label: l10n.levelIntermediate),
                              PickerOption(
                                  value: 'advanced',
                                  label: l10n.levelAdvanced),
                            ],
                            selected: [profile.level],
                          );
                          if (result != null && result.isNotEmpty) {
                            cubit.update(profile.copyWith(level: result.first));
                          }
                        },
                      ),
                      _divider(),
                      _SettingsRow(
                        emoji: '👶',
                        label: l10n.teachingLanguage,
                        value: Text(AppLanguages.labelOf(profile.nativeLanguage),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.itemSubtitle
                                .copyWith(fontSize: 19.sp)),
                        onTap: () async {
                          final result = await showPickerSheet(
                            context,
                            emoji: '👶',
                            title: l10n.teachingLanguage,
                            options: _languageOptions(AppLanguages.native),
                            selected: [profile.nativeLanguage],
                          );
                          if (result != null && result.isNotEmpty) {
                            cubit.update(
                                profile.copyWith(nativeLanguage: result.first));
                          }
                        },
                      ),
                      _divider(),
                      _SettingsRow(
                        emoji: '🎭',
                        label: l10n.interests,
                        value: Text(
                          profile.interests.map(interestLabel).join(', '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.itemSubtitle
                              .copyWith(fontSize: 19.sp),
                        ),
                        onTap: () async {
                          final result = await showPickerSheet(
                            context,
                            emoji: '🎭',
                            title: l10n.interests,
                            multiSelect: true,
                            visibleCount: 8,
                            options: [
                              PickerOption(
                                  value: 'technology',
                                  label: l10n.interestTechnology,
                                  emoji: '💻'),
                              PickerOption(
                                  value: 'travel',
                                  label: l10n.interestTravel,
                                  emoji: '✈️'),
                              PickerOption(
                                  value: 'cooking',
                                  label: l10n.interestCooking,
                                  emoji: '🍳'),
                              PickerOption(
                                  value: 'sports',
                                  label: l10n.interestSports,
                                  emoji: '⚽'),
                              PickerOption(
                                  value: 'music',
                                  label: l10n.interestMusic,
                                  emoji: '🎵'),
                              PickerOption(
                                  value: 'movies',
                                  label: l10n.interestMovies,
                                  emoji: '🎬'),
                              PickerOption(
                                  value: 'art',
                                  label: l10n.interestArt,
                                  emoji: '🎨'),
                              PickerOption(
                                  value: 'business',
                                  label: l10n.interestBusiness,
                                  emoji: '💼'),
                            ],
                            selected: profile.interests,
                          );
                          if (result != null && result.isNotEmpty) {
                            cubit.update(profile.copyWith(interests: result));
                          }
                        },
                      ),
                      _divider(),
                      _SettingsRow(
                        emoji: '⛳',
                        label: l10n.dailyGoal,
                        value: Text(l10n.minPerDay(profile.dailyGoalMinutes),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.itemSubtitle
                                .copyWith(fontSize: 19.sp)),
                        onTap: () async {
                          final result = await showPickerSheet(
                            context,
                            emoji: '⛳',
                            title: l10n.dailyGoal,
                            options: [
                              for (final m in [5, 10, 15, 20, 30])
                                PickerOption(
                                    value: '$m', label: l10n.minPerDay(m)),
                            ],
                            selected: ['${profile.dailyGoalMinutes}'],
                          );
                          if (result != null && result.isNotEmpty) {
                            cubit.update(profile.copyWith(
                                dailyGoalMinutes: int.parse(result.first)));
                          }
                        },
                      ),
                      _divider(),
                      _SettingsRow(
                        emoji: '🔔',
                        label: l10n.dailyReminder,
                        value: Text(
                          profile.reminderTime ?? l10n.disabled,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.itemSubtitle
                              .copyWith(fontSize: 19.sp),
                        ),
                        onTap: () => _pickReminder(context, profile, cubit),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 130.h),
          ],
        ),
      ),
    );
  }

  static Widget _divider() => Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child:
            const Divider(color: AppColors.background, thickness: 2, height: 2),
      );

  Future<void> _editName(BuildContext context, String current) async {
    Haptics.tap();
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<ProfileCubit>();
    final controller = TextEditingController(text: current);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        title: Text(l10n.tabProfile, style: AppTextStyles.modalTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(l10n.save, style: AppTextStyles.textLink),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      cubit.update(cubit.state.copyWith(name: name));
    }
  }

  Future<void> _pickReminder(
      BuildContext context, dynamic profile, ProfileCubit cubit) async {
    Haptics.tap();
    final l10n = AppLocalizations.of(context)!;
    final parts = (profile.reminderTime as String?)?.split(':');
    final initial = parts != null
        ? TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]))
        : const TimeOfDay(hour: 19, minute: 0);
    final time = await showTimePicker(context: context, initialTime: initial);
    if (time == null) return;
    final formatted =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    cubit.update(profile.copyWith(reminderTime: formatted));
    await ReminderService.schedule(
      hour: time.hour,
      minute: time.minute,
      title: l10n.appName,
      body: l10n.streakHelper,
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final String emoji;
  final String label;
  final Widget value;
  final VoidCallback onTap;

  const _SettingsRow({
    required this.emoji,
    required this.label,
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
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        child: Row(
          children: [
            Text(emoji, style: TextStyle(fontSize: 22.sp)),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.itemTitle.copyWith(fontSize: 20.sp)),
            ),
            SizedBox(width: 8.w),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 140.w),
              child: value,
            ),
            SizedBox(width: 6.w),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.textLightGrey, size: 26.r),
          ],
        ),
      ),
    );
  }
}
