import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widget/common_widgets.dart';
import '../cubit/feedback_cubit.dart';
import '../widget/feedback_card.dart';
import '../widget/feedback_empty_state.dart';

/// "Alternatives" page: alternative-phrasing feedback or the empty state.
class AlternativesScreen extends StatelessWidget {
  const AlternativesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = context.watch<FeedbackCubit>().state.alternatives;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SubPageHeader(title: l10n.alternatives),
          Expanded(
            child: items.isEmpty
                ? FeedbackEmptyState(text: l10n.noErrorsHere)
                : ListView.separated(
                    padding: EdgeInsets.all(20.r),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => SizedBox(height: 14.h),
                    itemBuilder: (_, i) => FeedbackCard(item: items[i]),
                  ),
          ),
        ],
      ),
    );
  }
}
