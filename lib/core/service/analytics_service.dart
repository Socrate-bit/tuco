import 'package:flutter/foundation.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

/// Mixpanel wrapper. All event tracking goes through this service.
/// Behaves as a no-op until [init] succeeds (e.g. missing token).
class AnalyticsService {
  static const _token = String.fromEnvironment('MIXPANEL_TOKEN');
  Mixpanel? _mixpanel;

  /// Initialize Mixpanel; no-op when no token is configured.
  Future<void> init() async {
    if (_token.isEmpty) {
      debugPrint('[AnalyticsService] No Mixpanel token — analytics disabled');
      return;
    }
    try {
      _mixpanel = await Mixpanel.init(_token, trackAutomaticEvents: true);
      debugPrint('[AnalyticsService] Mixpanel initialized');
    } catch (e) {
      debugPrint('[AnalyticsService] Init error: $e');
    }
  }

  /// Track a named event with optional properties.
  void track(String event, [Map<String, dynamic>? props]) {
    try {
      _mixpanel?.track(event, properties: props);
    } catch (e) {
      debugPrint('[AnalyticsService] Track error: $e');
    }
  }

  /// Identify the current user.
  void identify(String userId) {
    try {
      _mixpanel?.identify(userId);
    } catch (e) {
      debugPrint('[AnalyticsService] Identify error: $e');
    }
  }
}
