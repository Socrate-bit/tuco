import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widget/common_widgets.dart';
import '../widget/legal_sections.dart';

/// Privacy Policy screen for ECOM-PARIS LLC / Tuco app.
/// Legal copy is intentionally kept in English (single legal version).
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const SubPageHeader(title: 'Privacy Policy'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Privacy Policy',
                style: AppTextStyles.sectionTitle.copyWith(fontSize: 24.sp)),
            SizedBox(height: 12.h),
            const LegalParagraph(
                'This Privacy Policy explains how ECOM-PARIS LLC ("we", "our", "us") collects, uses, stores, and protects your personal information when you use Tuco or related services.'),
            SizedBox(height: 24.h),
            const LegalBulletSection('1. Information We Collect', [
              'Usage data (app interactions, lesson and call usage patterns)',
              'Anonymous account information (Firebase anonymous auth)',
              'Learning progress, vocabulary and session data stored in your Firestore profile',
            ]),
            const LegalBulletSection('2. How We Use Your Information', [
              'To provide and improve conversation, lesson, and analytics features',
              'To respond to user inquiries and customer support requests',
              'To send essential updates and comply with legal obligations',
            ]),
            const LegalParagraphSection('3. Microphone and Voice Data',
                'Tuco uses your device microphone to power AI conversation practice. Speech is converted to text on your device by iOS speech recognition.\n\nYour voice recording is sent to our pronunciation-scoring provider, which processes it transiently and does not retain it. The recording is also stored in your own Tuco account (Firebase Storage) so you can listen back to it; deleting your account deletes these recordings.\n\nWe do not collect, store, or retain any biometric or voice-print data.'),
            const LegalBulletSection('4. AI-Processed Data', [
              'Conversation features use third-party AI services to generate responses, score pronunciation and produce feedback. We ask for your explicit permission in the app before any of this data is sent, and you can withdraw it at any time in Settings',
              'Google Gemini (Google LLC) receives text only — your typed and transcribed messages plus your conversation context (first name, level, target language, lesson vocabulary and recent messages) — and generates Tuco\'s replies and language feedback. Your voice recording is not sent to Gemini. See Google\'s privacy policy at https://policies.google.com/privacy',
              'Azure AI Speech (Microsoft Corporation) receives only the reply text to read out loud, and returns the synthesized voice. See Microsoft\'s privacy statement at https://privacy.microsoft.com/privacystatement',
              'SpeechSuper receives your voice recording and the reference phrase in order to score your pronunciation, and returns the score. See https://www.speechsuper.com/privacy-policy',
              'Data sent to these AI providers is processed only for the requested task and is not retained by them after processing or reused to train their models',
              'No biometric data is extracted or stored during AI processing',
            ]),
            const LegalBulletSection('5. Sharing of Information', [
              'We do not sell or rent personal data',
              'We share data only with service providers (processors) who process it on our behalf and under our instructions: Google (Firebase Authentication, Cloud Firestore, Firebase Storage and Gemini AI), Microsoft (Azure AI Speech text-to-speech), SpeechSuper (pronunciation scoring), and Mixpanel (usage analytics)',
              'AI providers (Google Gemini, Microsoft Azure AI Speech, SpeechSuper) process data transiently for the requested service; Firebase Storage holds your voice recordings in your own account so you can replay them, and Mixpanel stores usage analytics to help us improve the app. None of these providers use your data for their own purposes',
            ]),
            const LegalParagraphSection('6. Data Security',
                'We use appropriate technical and organizational measures to protect all personal data against unauthorized access, alteration, loss, or misuse.'),
            const LegalParagraphSection('7. Your Rights',
                'You may request access, correction, or deletion of your personal data by contacting us directly. We respond to all verified requests in compliance with applicable privacy laws.'),
            const LegalParagraphSection('8. Policy Updates',
                'We may update this Privacy Policy periodically. Any revisions will be posted on this page with an updated effective date.'),
            const LegalContactSection('9. Contact Us',
                'For any questions regarding this Privacy Policy, please contact:'),
            const LegalBulletSection('10. Data Deletion Requests', [
              'You can delete all your data at any time by deleting your account in the app: go to Settings and tap "Delete account"',
              'Deleting your account permanently erases all personal data associated with it (learning progress, vocabulary, call history, and streaks)',
              'Alternatively, users can request deletion of all personal data associated with their account at any time',
              'Send an email to contact@ecomparis.org with the subject "Data Deletion Request"',
              'All verified deletion requests are processed within 30 days and cannot be undone once completed',
            ]),
            SizedBox(height: 24.h),
            const LegalFooter(),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}
