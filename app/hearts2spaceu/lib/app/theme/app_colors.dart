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

  /// The readable end of the brand hue. Every accent label, link, active tab,
  /// and solid CTA uses this.
  ///
  /// Held to AA on every ground it can land on — white, a glass card over any
  /// corner blob, and the wash itself with no card between. That last one is
  /// the strictest: "See all" sits straight on the wash, where the previous
  /// value read 3.57:1 over the sky blob. 4.60:1 there now, and white text on
  /// it as a CTA fill is 7.27:1.
  static const Color primaryStrong = Color(0xFF195B89);

  static const Color onPrimary = Color(0xFF16283C);

  static const Color secondary = Color(0xFFF8AFCB); // blossom pink

  /// The saved-heart pink. Only ever an icon, so the bar is WCAG 1.4.11's 3:1
  /// rather than 4.5:1 — but it has to hold that on every ground a heart sits
  /// on, including the pink end of the hero gradient, where the previous value
  /// read 1.97:1. 3.10:1 on the worst of them now. Not a text colour.
  static const Color secondaryStrong = Color(0xFFBD3272);

  static const Color ink = Color(0xFF16283C); // navy — primary text

  /// Secondary text: section labels, metadata, captions.
  ///
  /// Real text, so it is held to 4.5:1 like the rest — over a corner blob, which
  /// is where it is worst. The previous value cleared the pale base by 0.10 and
  /// dropped to 3.90:1 the moment a card sat on a blob. 4.60:1 there now.
  static const Color inkMuted = Color(0xFF56697C);

  /// Body copy, and any secondary text that sits straight on the wash.
  ///
  /// [inkMuted] is for text *inside* a glass card, where it is measured at
  /// 4.60:1. With no card between it and a corner blob it drops to 3.59:1 —
  /// so section headers, captions and taglines on the wash use this instead,
  /// which holds 4.80:1 there. Resolve it with [inkSoftOf] in widgets, since it
  /// has no ColorScheme role to carry its dark counterpart.
  static const Color inkSoft = Color(0xFF3F566E);

  /// Secondary text on a fixed pastel fill — the hero gradient, a light tint
  /// that stays light in dark mode. [inkSoft] reaches only 4.33:1 on the sky end
  /// of that gradient; this is the same hue taken to 4.60:1. Supplied to pastel
  /// surfaces as their `onSurfaceVariant` by `LightSurface`.
  static const Color pastelMuted = Color(0xFF3C5269);

  /// [inkSoft] for the current brightness.
  static Color inkSoftOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkInkSoft : inkSoft;

  static const Color background = Color(0xFFF1F7FC); // pale sky
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceTint = Color(0xFFE6F4FB); // sky tint
  static const Color outline = Color(0xFFDCEAF3);

  static const Color success = Color(0xFF6FC2A6);
  static const Color warning = Color(0xFFE8B65C);

  /// The error icon in failure states. An icon, so 3:1 — the previous coral
  /// reached only 2.41:1 on the light tint circle it sits in. 3.20:1 there now,
  /// and 3.86:1 on the dark tint.
  static const Color error = Color(0xFFDF5D5B);

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

  // --- Dark palette ----------------------------------------------------
  // Kept soft & desaturated (not pure black) so the "dreamy" feel survives in
  // dark mode too — a deep navy surface with the same sky/pink accents.
  static const Color darkBackground = Color(0xFF0D1620);
  static const Color darkSurface = Color(0xFF16232F);
  static const Color darkSurfaceTint = Color(0xFF1E2E3D);
  static const Color darkOutline = Color(0xFF2A3D4F);
  static const Color darkInk = Color(0xFFE8F1F8);

  /// Dark-mode [inkSoft]: between [darkInk] and [darkInkMuted], 7.00:1 on the
  /// lightest dark ground.
  static const Color darkInkSoft = Color(0xFFD4DDE6);

  /// Secondary text in dark mode. Held to AA over a dark card sitting on a
  /// blob (#394651), where the previous value reached only 4.46:1.
  static const Color darkInkMuted = Color(0xFFA2B6C6);
  static const Color darkPrimary = Color(0xFF87CEEB);
  static const Color darkOnPrimary = Color(0xFF0D1620);
  static const Color darkSecondary = Color(0xFFF5B9D2);
}
