import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:superwallkit_flutter/superwallkit_flutter.dart';

/// Configures the Superwall SDK at startup.
class SuperwallService {
  static const _key = 'pk_CQ3WsXRN9vvfQKgESbqmn';

  static bool get isConfigured => _key.isNotEmpty;

  static void configure() {
    if (!isConfigured) {
      debugPrint('[SuperwallService] No key — paywall disabled');
      return;
    }
    try {
      // Match paywall locale to the device locale (e.g. "en_US", "fr_FR").
      final options = SuperwallOptions()..localeIdentifier = Platform.localeName;
      Superwall.configure(_key, options: options);
      debugPrint('[SuperwallService] Superwall configured');
    } catch (e) {
      debugPrint('[SuperwallService] configure error: $e');
    }
  }
}
