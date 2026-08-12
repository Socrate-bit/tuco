import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/model/models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widget/common_widgets.dart';
import '../../call/widget/chat_bubbles.dart';
import '../../call/widget/feedback_sheet.dart';
import '../../feedback/cubit/feedback_cubit.dart';
import '../../profile/cubit/profile_cubit.dart';
import '../cubit/transcript_cubit.dart';

/// Read-only transcript of a past call, in the call-screen bubble style.
/// Translate, play and feedback actions stay usable on past messages.
class TranscriptScreen extends StatelessWidget {
  final CallRecord call;
  final String title;

  const TranscriptScreen({super.key, required this.call, required this.title});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TranscriptCubit(
        profile: context.read<ProfileCubit>().state,
        transcript: call.transcript,
      ),
      child: Scaffold(
        backgroundColor: AppColors.card,
        body: Column(
          children: [
            SubPageHeader(title: title),
            Expanded(
              child: BlocBuilder<TranscriptCubit, TranscriptState>(
                builder: (context, state) {
                  final cubit = context.read<TranscriptCubit>();
                  return ListView.separated(
                    padding: EdgeInsets.all(16.r),
                    itemCount: state.messages.length,
                    separatorBuilder: (_, _) => SizedBox(height: 14.h),
                    itemBuilder: (context, i) {
                      final msg = state.messages[i];
                      if (msg.banner != null) {
                        return PhaseBanner(banner: msg.banner!);
                      }
                      return switch (msg.role) {
                        MessageRole.ai => AiBubble(
                            message: msg,
                            translating: state.translatingIndex == i,
                            onTranslate: () => cubit.translateMessage(i),
                            onPlay: () => cubit.playMessage(i),
                          ),
                        MessageRole.user => UserBubble(
                            message: msg,
                            hasFeedback: context
                                .watch<FeedbackCubit>()
                                .state
                                .items
                                .any((f) => f.originalText == msg.text),
                            onFeedbackTap: () =>
                                showFeedbackSheet(context, msg.text),
                          ),
                        MessageRole.inspiration =>
                          InspirationBubble(message: msg),
                      };
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
