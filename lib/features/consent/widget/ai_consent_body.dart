import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/service/legal_links.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widget/common_widgets.dart';

/// The AI data disclosure itself: what leaves the device, who receives it and
/// what they do with it. Shared by the onboarding step, the gate that blocks an
/// AI call without consent, and the Settings review screen — so the wording the
/// user agreed to is the same everywhere, by construction.
class AiConsentBody extends StatelessWidget {
  const AiConsentBody({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.aiConsentTitle, style: AppTextStyles.pageTitle),
        SizedBox(height: 8.h),
        Text(l10n.aiConsentSubtitle, style: AppTextStyles.bodyGrey),
        SizedBox(height: 24.h),

        // What leaves the device.
        _SectionLabel(l10n.aiConsentSentTitle),
        AppCard(
          child: Column(children: [
            _Line(
                icon: Icons.mic_none_rounded, text: l10n.aiConsentSentVoice),
            _Line(
                icon: Icons.subtitles_outlined,
                text: l10n.aiConsentSentTranscript),
            _Line(
                icon: Icons.keyboard_alt_outlined,
                text: l10n.aiConsentSentTyped),
            _Line(
                icon: Icons.chat_bubble_outline_rounded,
                text: l10n.aiConsentSentContext,
                last: true),
          ]),
        ),
        SizedBox(height: 24.h),

        // Named recipients — one entry per provider that actually receives data.
        _SectionLabel(l10n.aiConsentRecipientsTitle),
        AppCard(
          child: Column(children: [
            _Provider(
              icon: Icons.psychology_outlined,
              color: AppColors.primary,
              name: l10n.aiConsentProviderGoogle,
              role: l10n.aiConsentProviderGoogleRole,
            ),
            _Provider(
              icon: Icons.record_voice_over_outlined,
              color: AppColors.teal,
              name: l10n.aiConsentProviderMicrosoft,
              role: l10n.aiConsentProviderMicrosoftRole,
            ),
            _Provider(
              icon: Icons.graphic_eq_rounded,
              color: AppColors.purple,
              name: l10n.aiConsentProviderSpeechSuper,
              role: l10n.aiConsentProviderSpeechSuperRole,
              last: true,
            ),
          ]),
        ),
        SizedBox(height: 24.h),

        // Processing that never leaves the phone — stated so the disclosure
        // isn't read as "everything you say is uploaded".
        _SectionLabel(l10n.aiConsentOnDeviceTitle),
        AppCard(
          child: _Line(
              icon: Icons.phone_iphone_rounded,
              text: l10n.aiConsentOnDeviceBody,
              last: true),
        ),
        SizedBox(height: 24.h),

        _SectionLabel(l10n.aiConsentUseTitle),
        AppCard(
          color: AppColors.primaryLight,
          child: Text(l10n.aiConsentUseBody,
              style: AppTextStyles.body.copyWith(fontSize: 16.sp)),
        ),
        SizedBox(height: 12.h),

        Center(
          child: TextLinkButton(
            label: l10n.aiConsentPrivacyLink,
            onPressed: () => openLegalLink(context, LegalLinks.privacyPolicy),
          ),
        ),
      ],
    );
  }
}

/// Small uppercase label above each card.
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h, left: 4.w),
      child: Text(text.toUpperCase(),
          style: AppTextStyles.small.copyWith(letterSpacing: 0.5)),
    );
  }
}

/// One bullet: icon + plain-language sentence.
class _Line extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool last;

  const _Line({required this.icon, required this.text, this.last = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20.r, color: AppColors.textGrey),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(text,
                style: AppTextStyles.body.copyWith(fontSize: 16.sp)),
          ),
        ],
      ),
    );
  }
}

/// One named recipient: who they are and what they do with the data.
class _Provider extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String name;
  final String role;
  final bool last;

  const _Provider({
    required this.icon,
    required this.color,
    required this.name,
    required this.role,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38.r,
            height: 38.r,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20.r, color: color),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: AppTextStyles.itemTitle.copyWith(fontSize: 17.sp)),
                SizedBox(height: 2.h),
                Text(role,
                    style: AppTextStyles.itemSubtitle.copyWith(fontSize: 15.sp)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
