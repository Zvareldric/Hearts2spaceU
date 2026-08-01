import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Named type scale (docs/09 §3 — Material 3 style roles).
///
/// Built on the system font (SF Pro on Apple platforms, Roboto elsewhere) so
/// V1 ships with zero new font assets/dependencies; a bundled brand font is a
/// future evolution, not a V1 decision.
class AppTypography {
  const AppTypography._();

  static TextTheme textTheme(Color ink) {
    return TextTheme(
      displaySmall: TextStyle(
        fontSize: 32,
        height: 40 / 32,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: ink,
      ),
      // Tab page title — the large inline heading that replaced the AppBar in
      // Design System V2 (Gallery, Schedule, My Collection, More).
      headlineMedium: TextStyle(
        fontSize: 26,
        height: 32 / 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: ink,
      ),
      // Sub-page title, next to the round back button.
      headlineSmall: TextStyle(
        fontSize: 22,
        height: 28 / 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: ink,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        height: 24 / 18,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      bodyLarge: TextStyle(fontSize: 16, height: 24 / 16, color: ink),
      bodyMedium: TextStyle(fontSize: 14, height: 20 / 14, color: ink),
      labelMedium: TextStyle(
        fontSize: 13,
        height: 16 / 13,
        fontWeight: FontWeight.w500,
        color: ink,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        height: 14 / 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: ink,
      ),
    );
  }

  static final light = textTheme(AppColors.ink);
  static final dark = textTheme(AppColors.darkInk);
}
