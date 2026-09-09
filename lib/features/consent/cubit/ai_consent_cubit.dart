import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/service/analytics_service.dart';
import '../service/ai_consent_service.dart';
import 'ai_consent_state.dart';

/// UI-facing view of [AiConsentService]. The service owns the decision (it is
/// read by services with no BuildContext); this cubit only mirrors it so
/// screens rebuild the moment consent is granted or withdrawn.
class AiConsentCubit extends Cubit<AiConsentState> {
  final AnalyticsService _analytics;
  StreamSubscription<bool>? _sub;

  AiConsentCubit(this._analytics)
      : super(AiConsentState(granted: AiConsentService.isGranted)) {
    _sub = AiConsentService.changes.listen((granted) {
      if (!isClosed) emit(AiConsentState(granted: granted));
    });
  }

  /// User tapped "Agree and continue". [source] is where the screen was shown
  /// from ('onboarding', 'call', 'settings') so the funnel stays measurable.
  Future<void> grant(String source) async {
    await AiConsentService.grant();
    _analytics.track('ai_consent_granted',
        {'source': source, 'version': kAiConsentVersion});
    debugPrint('[AiConsentCubit] Granted from $source');
  }

  /// User tapped "Not now", or withdrew from Settings.
  Future<void> withdraw(String source) async {
    await AiConsentService.withdraw();
    _analytics.track('ai_consent_declined', {'source': source});
    debugPrint('[AiConsentCubit] Withdrawn from $source');
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
