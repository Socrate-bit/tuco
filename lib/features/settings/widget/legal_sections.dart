import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_theme.dart';

/// Shared building blocks for the legal pages (privacy policy, terms).
class LegalParagraph extends StatelessWidget {
  final String text;
  const LegalParagraph(this.text, {super.key});

  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppTextStyles.itemSubtitle);
}

class LegalParagraphSection extends StatelessWidget {
  final String title;
  final String content;
  const LegalParagraphSection(this.title, this.content, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.itemTitle),
          SizedBox(height: 8.h),
          LegalParagraph(content),
        ],
      ),
    );
  }
}

class LegalBulletSection extends StatelessWidget {
  final String title;
  final List<String> items;
  const LegalBulletSection(this.title, this.items, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.itemTitle),
          SizedBox(height: 8.h),
          ...items.map((item) => Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const LegalParagraph('• '),
                    Expanded(child: LegalParagraph(item)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class LegalContactSection extends StatelessWidget {
  final String title;
  final String intro;
  const LegalContactSection(this.title, this.intro, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.itemTitle),
          SizedBox(height: 8.h),
          LegalParagraph(intro),
          SizedBox(height: 8.h),
          const LegalParagraph('Email: contact@ecomparis.org'),
          SizedBox(height: 4.h),
          const LegalParagraph(
              'Address: 8206 LOUISIANA BLVD NE, STE A #2226, Albuquerque, NM 87113, USA'),
        ],
      ),
    );
  }
}

class LegalFooter extends StatelessWidget {
  const LegalFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('© 2025 ECOM-PARIS LLC. All rights reserved.',
          style: AppTextStyles.small),
    );
  }
}
