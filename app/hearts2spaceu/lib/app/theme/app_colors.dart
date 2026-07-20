import 'package:flutter/material.dart';

/// Brand color tokens — Design System V1 (docs/09 defers concrete values to
/// visual design; this file is that decision).
///
/// Reference these instead of hard-coding `Color(0x...)` throughout the UI.
/// Palette: baby blue (primary) + baby pink (secondary) on a soft, dreamy,
/// light-first surface, with a navy ink for text.
class AppColors {
  const AppColors._();

  // --- Light palette -------------------------------------------------
  static const Color primary = Color(0xFF8CC5F2); // baby blue
  static const Color primaryStrong = Color(0xFF2F7CC0); // AA-safe on white
  static const Color onPrimary = Color(0xFF12233F);

  static const Color secondary = Color(0xFFF7C5D9); // baby pink
  static const Color secondaryStrong = Color(0xFFD96FA0); // AA-safe on white

  static const Color ink = Color(0xFF1E2A46); // navy — primary text
  static const Color inkMuted = Color(0xFF5B6478); // navy — secondary text

  static const Color background = Color(0xFFF6FAFE); // very light blue
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceTint = Color(0xFFEAF3FC);
  static const Color outline = Color(0xFFE4EAF2);

  static const Color success = Color(0xFF57C4A3);
  static const Color warning = Color(0xFFF0C15E);
  static const Color error = Color(0xFFE6807F);

  /// Hero / brand gradient — very soft blue → pink.
  static const List<Color> heroGradient = [
    Color(0xFFEAF3FC),
    Color(0xFFFCEBF2),
  ];

  // --- Type badge tints (per Event.type) ------------------------------
  static const Color badgeConcertBg = Color(0xFFEAF3FC);
  static const Color badgeBroadcastBg = Color(0xFFFCEBF2);
  static const Color badgeShowcaseBg = Color(0xFFEAF7F1);
  static const Color badgeFanmeetingBg = Color(0xFFF3EEFC);

  // --- Dark palette ----------------------------------------------------
  // Kept soft & desaturated (not pure black) so the "calm" feel survives in
  // dark mode too — a deep navy surface with the same blue/pink accents.
  static const Color darkBackground = Color(0xFF0F1626);
  static const Color darkSurface = Color(0xFF17203A);
  static const Color darkSurfaceTint = Color(0xFF1E2A46);
  static const Color darkOutline = Color(0xFF2B3652);
  static const Color darkInk = Color(0xFFEAF1FB);
  static const Color darkInkMuted = Color(0xFFAEB8CE);
  static const Color darkPrimary = Color(0xFF8CC5F2);
  static const Color darkOnPrimary = Color(0xFF0B1B2E);
  static const Color darkSecondary = Color(0xFFF0AAC7);
}
