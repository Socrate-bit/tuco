import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import 'haptics.dart';

/// The legal documents, hosted online rather than shipped in the binary so a
/// wording change (a new AI provider, a new retention rule) goes live without
/// an App Store release — and so the in-app text can never drift from the
/// published policy.
abstract class LegalLinks {
  /// GitHub Pages, not the repository's /blob/ URL: /blob/ opens GitHub's
  /// source viewer and shows the policy as raw HTML. Same file, same repo,
  /// same branch — just served rendered.
  static const privacyPolicy =
      'https://socrate-bit.github.io/app-support/tuco-privacy.html';
  static const terms = 'https://ecomparis.org/terms.html';
}

/// Opens a legal document in the device browser. Feedback is shown only when
/// the link fails to open.
Future<void> openLegalLink(BuildContext context, String url) async {
  Haptics.tap();
  final l10n = AppLocalizations.of(context)!;
  final messenger = ScaffoldMessenger.of(context);
  try {
    final opened =
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (opened) {
      debugPrint('[LegalLinks] Opened $url');
      return;
    }
    debugPrint('[LegalLinks] launchUrl refused $url');
  } catch (e) {
    debugPrint('[LegalLinks] open error for $url: $e');
  }
  messenger.showSnackBar(SnackBar(content: Text(l10n.legalLinkError)));
}
