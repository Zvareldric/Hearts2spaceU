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

  /// The readable end of the brand hue. Every accent label, active tab, and
  /// solid CTA uses this.
  ///
  /// Held to AA against the **darkest ground a card can sit on** — glass over a
  /// corner blob at full strength (#FCE1EC), not the pale base. Measured on the
  /// base alone it looked comfortable at 4.85:1; over a pink blob the same token
  /// was 4.41:1 and failed. 4.60:1 there now.
  static const Color primaryStrong = Color(0xFF1E6CA3);

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
  /// Real text, so it is held to 4.5:1 like the rest — over a corner blob, which
  /// is where it is worst. The previous value cleared the pale base by 0.10 and
  /// dropped to 3.90:1 the moment a card sat on a blob. 4.60:1 there now.
  static const Color inkMuted = Color(0xFF56697C);

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
  /// An icon, not text, so the bar is WCAG 1.4.11's 3:1 rather than 4.5:1 — and
  /// the nav bar floats over whatever scrolls beneath it, so the blob ground is
  /// the honest one to measure against. 2.62:1 there before; 3.15:1 now.
  static const Color navIdle = Color(0xFF5288A9);

  // --- Dark palette ----------------------------------------------------
  // Kept soft & desaturated (not pure black) so the "dreamy" feel survives in
  // dark mode too — a deep navy surface with the same sky/pink accents.
  static const Color darkBackground = Color(0xFF0D1620);
  static const Color darkSurface = Color(0xFF16232F);
  static const Color darkSurfaceTint = Color(0xFF1E2E3D);
  static const Color darkOutline = Color(0xFF2A3D4F);
  static const Color darkInk = Color(0xFFE8F1F8);

  /// Secondary text in dark mode. Held to AA over a dark card sitting on a
  /// blob (#394651), where the previous value reached only 4.46:1.
  static const Color darkInkMuted = Color(0xFFA2B6C6);
  static const Color darkPrimary = Color(0xFF87CEEB);
  static const Color darkOnPrimary = Color(0xFF0D1620);
  static const Color darkSecondary = Color(0xFFF5B9D2);
}
