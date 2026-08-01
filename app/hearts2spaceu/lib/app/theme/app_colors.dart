import 'package:flutter/material.dart';

/// Brand color tokens — Design System V2 ("liquid glass").
///
/// Reference these instead of hard-coding `Color(0x...)` throughout the UI.
/// Palette: sky blue (primary) + blossom pink (secondary) floating on a soft
/// pastel wash, with a deep plum ink for text. Surfaces are translucent white
/// rather than solid, so the ambient background reads through every card.
///
/// [primary] and [primaryStrong] are **not interchangeable**. The brand sky blue
/// is a light tint: it reaches only 1.74:1 against white, so it can fill a shape
/// but can never carry text or an icon. Anything a user has to *read* uses
/// [primaryStrong], which is the same hue taken down to 5.39:1 on white and
/// 4.85:1 on a glass card — AA in both places. Swapping one for the other is how
/// this palette breaks.
class AppColors {
  const AppColors._();

  // --- Light palette -------------------------------------------------
  /// Brand sky blue. **Fills only** — see the class note on contrast.
  static const Color primary = Color(0xFF87CEEB);

  /// The readable end of the brand hue: AA on white (5.39:1) and on glass
  /// (4.85:1). Every accent label, active tab, and solid CTA uses this.
  static const Color primaryStrong = Color(0xFF1F6FA8);

  static const Color onPrimary = Color(0xFF16283C);

  static const Color secondary = Color(0xFFF8AFCB); // blossom pink

  /// The saved-heart pink. 3.1:1 on white — that clears the 3:1 minimum for a
  /// non-text control (WCAG 1.4.11), which is all it is used for. It is **not**
  /// AA for body text, so don't reach for it as a text color; use
  /// [primaryStrong] or [ink].
  static const Color secondaryStrong = Color(0xFFD96FA0);

  static const Color ink = Color(0xFF16283C); // navy — primary text

  /// Secondary text: section labels, metadata, captions.
  ///
  /// Real text, so it is held to 4.5:1 like the rest — the plum it replaced sat
  /// at 3.5:1 and never met it.
  static const Color inkMuted = Color(0xFF60758A);

  /// Body copy inside a glass card — darker than [inkMuted], softer than [ink].
  static const Color inkSoft = Color(0xFF3F566E);

  static const Color background = Color(0xFFF1F7FC); // pale sky
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceTint = Color(0xFFE6F4FB); // sky tint
  static const Color outline = Color(0xFFDCEAF3);

  static const Color success = Color(0xFF6FC2A6);
  static const Color warning = Color(0xFFE8B65C);
  static const Color error = Color(0xFFE6807F);

  /// Hero / brand gradient — sky blue → pink.
  static const List<Color> heroGradient = [
    Color(0xFF87CEEB),
    Color(0xFFF8AFCB),
  ];

  // --- Glass surfaces --------------------------------------------------
  // Cards are a translucent white veil over the ambient background, edged with
  // a brighter hairline so they read as a pane of glass rather than a fade.
  static const Color glass = Color(0x8CFFFFFF); // white @ 55%
  static const Color glassBorder = Color(0xB3FFFFFF); // white @ 70%
  static const Color darkGlass = Color(0x14FFFFFF); // white @ 8%
  static const Color darkGlassBorder = Color(0x26FFFFFF); // white @ 15%

  /// Shadow tint — a cool blue, not neutral black, so depth stays in-palette.
  static const Color shadowTint = Color(0xFF4F87AD);

  // --- Ambient background wash ----------------------------------------
  /// The base vertical gradient the pastel blobs sit on.
  static const List<Color> ambientBase = [Color(0xFFF1F7FC), Color(0xFFFBF1F6)];
  static const List<Color> darkAmbientBase = [
    Color(0xFF0D1620),
    Color(0xFF221520),
  ];

  /// The four corner blobs, in the order the background paints them
  /// (top-left, top-right, bottom-right, bottom-left).
  ///
  /// Two sky, two pink — the wash is built from [primary] and [secondary] alone,
  /// so the background cannot drift away from the brand.
  static const List<Color> ambientBlobs = [
    Color(0xFFB8E2F5),
    Color(0xFFFBC9DE),
    Color(0xFFF8AFCB),
    Color(0xFF87CEEB),
  ];

  // --- Navigation ------------------------------------------------------
  /// An unselected nav destination — present, but clearly not where you are.
  ///
  /// An icon, not text, so the bar is WCAG 1.4.11's 3:1 rather than 4.5:1. The
  /// tint it replaced sat at 1.7:1 — visible only if you already knew it was
  /// there.
  static const Color navIdle = Color(0xFF6496B4);

  // --- Dark palette ----------------------------------------------------
  // Kept soft & desaturated (not pure black) so the "dreamy" feel survives in
  // dark mode too — a deep navy surface with the same sky/pink accents.
  static const Color darkBackground = Color(0xFF0D1620);
  static const Color darkSurface = Color(0xFF16232F);
  static const Color darkSurfaceTint = Color(0xFF1E2E3D);
  static const Color darkOutline = Color(0xFF2A3D4F);
  static const Color darkInk = Color(0xFFE8F1F8);
  static const Color darkInkMuted = Color(0xFF9FB3C4);
  static const Color darkPrimary = Color(0xFF87CEEB);
  static const Color darkOnPrimary = Color(0xFF0D1620);
  static const Color darkSecondary = Color(0xFFF5B9D2);
}
