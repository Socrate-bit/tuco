import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/service/haptics.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widget/common_widgets.dart';
import '../../call/service/tts_service.dart';
import '../../profile/cubit/profile_cubit.dart';
import '../cubit/vocab_cubit.dart';

/// "Exercice de vocabulaire": Appris / À venir tabs + word list with TTS.
class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  int _tab = 0;
  final _tts = TtsService();

  @override
  void initState() {
    super.initState();
    _tts.init(context.read<ProfileCubit>().state.targetLanguage);
  }

  @override
  void dispose() {
    _tts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vocab = context.watch<VocabCubit>().state;

    final words = _tab == 0
        ? [for (final w in vocab.learned) (word: w.word, translation: w.translation)]
        : [for (final w in vocab.upcoming) (word: w.word, translation: w.translation)];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SubPageHeader(title: l10n.vocabExercise),
          // Tabs row on white background.
          Container(
            color: AppColors.card,
            child: Row(
              children: [
                _Tab(
                  label: l10n.learnedTab,
                  count: vocab.learnedCount,
                  selected: _tab == 0,
                  onTap: () => setState(() => _tab = 0),
                ),
                _Tab(
                  label: l10n.upcomingTab,
                  count: vocab.upcomingCount,
                  selected: _tab == 1,
                  onTap: () => setState(() => _tab = 1),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(20.r),
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  child: Column(
                    children: [
                      for (var i = 0; i < words.length; i++) ...[
                        if (i > 0)
                          const Divider(
                              color: AppColors.divider,
                              thickness: 1,
                              height: 1),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 18.w, vertical: 14.h),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Haptics.tap();
                                  _tts.speak(words[i].word);
                                },
                                child: Container(
                                  width: 54.r,
                                  height: 54.r,
                                  decoration: const BoxDecoration(
                                      color: AppColors.background,
                                      shape: BoxShape.circle),
                                  child: Icon(Icons.volume_up_rounded,
                                      color: AppColors.primary, size: 26.r),
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(words[i].word,
                                        style: AppTextStyles.itemTitle
                                            .copyWith(fontSize: 21.sp)),
                                    SizedBox(height: 2.h),
                                    Text(words[i].translation,
                                        style: AppTextStyles.itemSubtitle
                                            .copyWith(fontSize: 18.sp)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.navy : AppColors.textLightGrey;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Haptics.select();
          onTap();
        },
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label,
                      style: AppTextStyles.itemTitle
                          .copyWith(color: color, fontSize: 20.sp)),
                  SizedBox(width: 10.w),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.navy : AppColors.background,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Text(
                      '$count',
                      style: AppTextStyles.small.copyWith(
                        fontSize: 15.sp,
                        color:
                            selected ? Colors.white : AppColors.textGrey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 3.h,
              margin: EdgeInsets.symmetric(horizontal: 30.w),
              decoration: BoxDecoration(
                color: selected ? AppColors.navy : Colors.transparent,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
