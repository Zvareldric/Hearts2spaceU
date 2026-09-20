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

  /// How many lines text that is kept to [lines] at normal size may take at
  /// the reader's text size.
  ///
  /// WCAG 1.4.4 asks that text enlarged to 200% loses no content. A one-line
  /// title that fits at 100% needs two lines at 200% to show the same words;
  /// held to one, it silently turns into "…" — and the sweep found page titles,
  /// stat labels and every subtitle in More doing exactly that. Scaling the
  /// limit with the text keeps what a reader sees at 200% at least what they
  /// see at 100%, while a deliberate one-line row stays one line at 100%.
  ///
  /// The factor is read at body size rather than at 1px: Android's nonlinear
  /// font scaling enlarges small text more than large, so `scale(1)` would
  /// understate it for the sizes these limits actually govern.
  static int maxLines(BuildContext context, int lines) {
    final factor = MediaQuery.textScalerOf(context).scale(14) / 14;
    return factor <= 1 ? lines : (lines * factor).ceil();
  }

  /// The exact height of [lines] lines of [style] at the reader's text size.
  ///
  /// For a row that has to reserve room for text before it lays the text out —
  /// a horizontal strip needs a height up front. Every style in this theme sets
  /// its line height, so this is arithmetic, not an estimate.
  static double linesHeight(BuildContext context, TextStyle style, int lines) =>
      MediaQuery.textScalerOf(context).scale(style.fontSize!) *
      (style.height ?? 1) *
      lines;

  static final light = textTheme(AppColors.ink);
  static final dark = textTheme(AppColors.darkInk);
}
