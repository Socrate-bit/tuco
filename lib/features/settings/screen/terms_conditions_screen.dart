import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widget/common_widgets.dart';
import '../widget/legal_sections.dart';

/// Terms and Conditions screen for ECOM-PARIS LLC / Tuco app.
/// Legal copy is intentionally kept in English (single legal version).
class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const SubPageHeader(title: 'Terms of Service'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Terms of Service',
                style: AppTextStyles.sectionTitle.copyWith(fontSize: 24.sp)),
            SizedBox(height: 12.h),
            const LegalParagraph(
                'Welcome to Tuco, developed by ECOM-PARIS LLC. By accessing or using our app, services, or related applications, you agree to comply with and be bound by the following terms and conditions.'),
            SizedBox(height: 24.h),
            const LegalParagraphSection('1. Use of Services',
                'You agree to use Tuco only for lawful purposes and in accordance with these Terms. You may not use our services to infringe upon the rights of others or to engage in any harmful or illegal activity.'),
            const LegalParagraphSection('2. Intellectual Property',
                'All content, trademarks, logos, and materials provided in this app are the property of ECOM-PARIS LLC or its licensors. You may not reproduce, distribute, or create derivative works without prior written consent.'),
            const LegalParagraphSection('3. Microphone and Voice Usage',
                'Tuco uses your device microphone solely to power AI conversation practice (e.g., transcribing your speech and generating responses during calls). Voice data is processed transiently — audio recordings are never stored or retained by Tuco or any third party after processing.'),
            const LegalParagraphSection('4. Privacy',
                'Your use of our services is also governed by our Privacy Policy, which explains how we collect, use, and protect your personal information.'),
            const LegalParagraphSection('5. Limitation of Liability',
                'ECOM-PARIS LLC is not liable for any direct, indirect, incidental, or consequential damages arising from your use of our services or inability to access them.'),
            const LegalParagraphSection('6. Changes to Terms',
                'We reserve the right to update or modify these Terms of Service at any time. Continued use of our services after changes constitutes acceptance of the new terms.'),
            const LegalParagraphSection('7. Governing Law',
                'These Terms are governed by the laws of the State of New Mexico, USA, without regard to conflict of law principles.'),
            const LegalContactSection('8. Contact Information',
                'If you have questions about these Terms, please contact us:'),
            SizedBox(height: 24.h),
            const LegalFooter(),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}
