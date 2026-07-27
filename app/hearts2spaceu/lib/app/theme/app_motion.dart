import 'package:flutter/material.dart';

/// Motion tokens — durations and curves (docs/design-system-v1.md §8).
///
/// Animation should support understanding, not decorate: short durations, a
/// gentle ease, and nothing that gets in the user's way.
class AppMotion {
  const AppMotion._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);

  /// Entering the screen.
  static const Curve enter = Curves.easeOutCubic;

  /// Changing between states.
  static const Curve change = Curves.easeInOut;

  /// [duration], or [Duration.zero] when the platform asks for reduced motion.
  ///
  /// Every animated widget in the app routes its duration through this, so
  /// accessibility settings disable motion app-wide (docs/09 §9).
  static Duration of(BuildContext context, Duration duration) {
    return MediaQuery.of(context).disableAnimations ? Duration.zero : duration;
  }
}
