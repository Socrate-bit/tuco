import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widget/common_widgets.dart';
import '../../progression/cubit/stats_cubit.dart';
import '../widget/call_card.dart';

/// Full "Historique des appels" list page.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final calls = context.watch<StatsCubit>().state.calls;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SubPageHeader(title: l10n.callHistory),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.all(20.r),
              itemCount: calls.length,
              separatorBuilder: (_, _) => SizedBox(height: 14.h),
              itemBuilder: (_, i) => CallCard(call: calls[i]),
            ),
          ),
        ],
      ),
    );
  }
}
