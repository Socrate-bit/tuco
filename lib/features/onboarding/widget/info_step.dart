import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_theme.dart';

/// Education page: title, subtitle and a centered illustration widget.
/// Content centers while it fits and scrolls when it doesn't.
class InfoStep extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const InfoStep(
      {super.key, required this.title, this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight - 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.pageTitle),
              if (subtitle != null) ...[
                SizedBox(height: 8.h),
                Text(subtitle!, style: AppTextStyles.bodyGrey),
              ],
              SizedBox(height: 24.h),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
