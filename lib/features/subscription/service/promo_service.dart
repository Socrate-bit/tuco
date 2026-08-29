import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

/// Promo code validation and redemption.
///
/// Validation reads `promoCodes/{code}` directly so the onboarding funnel can
/// give instant feedback; redemption goes through the `redeemPromoCode` Cloud
/// Function, which owns the atomic increment and the `user_type` write.
class PromoService {
  static const exhausted = 'exhausted';

  static final _codes = FirebaseFirestore.instance.collection('promoCodes');
  static final _redeem = FirebaseFunctions.instanceFor(region: 'europe-west1')
      .httpsCallable('redeemPromoCode');

  /// Client-side pre-validation. Returns the code's type string when valid,
  /// [exhausted] when `num_use >= max_use`, or null when invalid/missing.
  static Future<String?> validateCode(String code) async {
    try {
      final doc = await _codes.doc(code).get();
      if (!doc.exists) return null;
      final data = doc.data()!;
      final type = data['type'] as String?;
      final numUse = data['num_use'] as int?;
      final maxUse = data['max_use'] as int?;
      // All required fields must be present.
      if (type == null || numUse == null || maxUse == null) return null;
      if (numUse >= maxUse) return exhausted;
      return type;
    } catch (e) {
      debugPrint('[PromoService] validateCode error: $e');
      return null;
    }
  }

  /// Redeems [code] and returns the granted user_type string. Throws on
  /// failure so callers can surface the error.
  static Future<String> redeemCode(String code) async {
    final result = await _redeem.call<Map<String, dynamic>>({'code': code});
    final type = result.data['user_type'] as String;
    debugPrint('[PromoService] Code "$code" redeemed → $type');
    return type;
  }
}
