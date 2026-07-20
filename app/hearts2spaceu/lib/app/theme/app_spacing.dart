/// Spacing tokens — a base-4 scale with named steps (docs/09 §4).
///
/// Use these instead of magic numbers for padding, margin, and gaps.
class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Standard screen edge padding.
  static const double screenPadding = xl;

  /// Standard card inner padding.
  static const double cardPadding = lg;
}
