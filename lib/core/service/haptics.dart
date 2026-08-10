import 'package:flutter/services.dart';

/// Central haptic feedback helper — every user interaction triggers haptics.
abstract class Haptics {
  /// Light tap for standard interactions (buttons, list items, toggles).
  static void tap() => HapticFeedback.lightImpact();

  /// Medium impact for significant actions (start call, complete lesson).
  static void impact() => HapticFeedback.mediumImpact();

  /// Success/celebration moments (streak win, lesson end).
  static void success() => HapticFeedback.heavyImpact();

  /// Selection change (tabs, chips, pickers).
  static void select() => HapticFeedback.selectionClick();
}
