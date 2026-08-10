import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/model/models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widget/common_widgets.dart';
import '../../call/widget/chat_bubbles.dart';

/// Read-only transcript of a past call, in the call-screen bubble style.
class TranscriptScreen extends StatelessWidget {
  final CallRecord call;
  final String title;

  const TranscriptScreen({super.key, required this.call, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.card,
      body: Column(
        children: [
          SubPageHeader(title: title),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.all(16.r),
              itemCount: call.transcript.length,
              separatorBuilder: (_, _) => SizedBox(height: 14.h),
              itemBuilder: (context, i) {
                final msg = call.transcript[i];
                if (msg.banner != null) return PhaseBanner(banner: msg.banner!);
                return switch (msg.role) {
                  MessageRole.ai => AiBubble(
                      message: msg,
                      translating: false,
                      onTranslate: () {},
                      onPlay: () {},
                    ),
                  MessageRole.user =>
                    UserBubble(message: msg, onFeedbackTap: () {}),
                  MessageRole.inspiration => InspirationBubble(message: msg),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}
