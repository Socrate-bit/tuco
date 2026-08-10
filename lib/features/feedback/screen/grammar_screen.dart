import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/service/haptics.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widget/common_widgets.dart';
import '../cubit/feedback_cubit.dart';
import '../widget/feedback_card.dart';

/// "Grammaire" page: score filter chips + expandable feedback cards.
class GrammarScreen extends StatefulWidget {
  const GrammarScreen({super.key});

  @override
  State<GrammarScreen> createState() => _GrammarScreenState();
}

class _GrammarScreenState extends State<GrammarScreen> {
  int _filter = 0; // 0 all, 1 excellent, 2 can do better, 3 needs improvement

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = context.watch<FeedbackCubit>().state.grammar;

    final filtered = switch (_filter) {
      1 => items.where((i) => scoreBandOf(i.score) == ScoreBand.excellent),
      2 => items.where((i) => scoreBandOf(i.score) == ScoreBand.canDoBetter),
      3 => items
          .where((i) => scoreBandOf(i.score) == ScoreBand.needsImprovement),
      _ => items,
    }
        .toList();

    final chips = [
      l10n.filterAll,
      l10n.scoreExcellent,
      l10n.scoreCanDoBetter,
      l10n.scoreNeedsImprovement,
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SubPageHeader(title: l10n.grammar),
          // Filter chips row.
          Container(
            color: AppColors.card,
            padding: EdgeInsets.only(bottom: 14.h),
            child: SizedBox(
              height: 48.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: chips.length,
                separatorBuilder: (_, _) => SizedBox(width: 12.w),
                itemBuilder: (_, i) {
                  final selected = _filter == i;
                  return GestureDetector(
                    onTap: () {
                      Haptics.select();
                      setState(() => _filter = i);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 22.w),
                      decoration: BoxDecoration(
                        color:
                            selected ? AppColors.primary : AppColors.card,
                        borderRadius: BorderRadius.circular(24.r),
                        border: selected
                            ? null
                            : Border.all(
                                color: AppColors.divider, width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        chips[i],
                        style: AppTextStyles.chip.copyWith(
                          fontSize: 18.sp,
                          color:
                              selected ? Colors.white : AppColors.textDark,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.all(20.r),
              itemCount: filtered.length,
              separatorBuilder: (_, _) => SizedBox(height: 14.h),
              itemBuilder: (_, i) => FeedbackCard(item: filtered[i]),
            ),
          ),
        ],
      ),
    );
  }
}

enum ScoreBand { excellent, canDoBetter, needsImprovement }

ScoreBand scoreBandOf(int score) {
  if (score >= 85) return ScoreBand.excellent;
  if (score >= 60) return ScoreBand.canDoBetter;
  return ScoreBand.needsImprovement;
}
