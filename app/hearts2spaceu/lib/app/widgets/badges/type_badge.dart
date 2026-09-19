import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';

/// The look of one type: a tinted pill with matching ink, and the label to
/// print (so `fanmeeting` reads as "Fan Meeting", not as its data value).
typedef TypeStyle = ({Color background, Color foreground, String label});

/// Every type present in `events.json`, plus `showcase` which the schema still
/// allows. Tints are translucent so the glass card reads through them.
///
/// The tints come from the source design; the **foregrounds do not**. The mock's
/// own label colors landed between 2.9:1 and 4.0:1 once composited over a glass
/// card — six of the seven failed AA for 9.5px bold text. These are the same
/// hues taken down until each one clears 4.5:1 against its own tint, so the
/// design's color coding survives and the labels are actually readable.
///
/// "Against its own tint" means on every ground the pill can sit on: a glass
/// card over each of the six places on the wash, and the pastel hero gradient
/// at the top of a detail page. Five of these first cleared the cards only and
/// fell to 3.81:1–4.39:1 on the hero. Locked by
/// `test/app/theme/app_colors_contrast_test.dart`.
const Map<String, TypeStyle> _styles = {
  'concert': (
    background: Color(0x8C87CEEB),
    foreground: Color(0xFF145377),
    label: 'Concert',
  ),
  'broadcast': (
    background: Color(0x8CF8AFCB),
    foreground: Color(0xFF872D54),
    label: 'Broadcast',
  ),
  // Teal, not the periwinkle it was: violet is out of the palette, and teal is
  // the one cool hue left that is not already `concert` (sky) or `event` (slate).
  'fanmeeting': (
    background: Color(0x80A8E0E8),
    foreground: Color(0xFF0F5561),
    label: 'Fan Meeting',
  ),
  'release': (
    background: Color(0x8CFAC8DC),
    foreground: Color(0xFF8F305B),
    label: 'Release',
  ),
  // Slate, not the blue it was: `concert` took the brand sky blue, and two blue
  // badges would stop telling the two event types apart. Slate also suits the
  // most generic type in the vocabulary.
  'event': (
    background: Color(0x8CD5DCE8),
    foreground: Color(0xFF47566B),
    label: 'Event',
  ),
  'award': (
    background: Color(0x99FFE0B4),
    foreground: Color(0xFF79551B),
    label: 'Award',
  ),
  'showcase': (
    background: Color(0x8CC6EFDF),
    foreground: Color(0xFF2B6551),
    label: 'Showcase',
  ),
};

/// The tint/ink pairs, exposed so the contrast test can assert every one of them
/// rather than trusting the table above.
@visibleForTesting
Map<String, TypeStyle> get typeBadgeStyles => _styles;

/// The tint and label for [type].
///
/// An unmapped or missing type still gets a readable style in the neutral tint:
/// its own value with hyphens opened up, so `music-show` reads as "Music Show".
/// That is what lets features with their own vocabulary (Awards, Voting) reuse
/// this without the map having to learn every domain.
TypeStyle typeStyleFor(String? type) {
  if (type == null) {
    return (
      background: AppColors.surfaceTint,
      foreground: AppColors.primaryStrong,
      label: '',
    );
  }
  return _styles[type.toLowerCase()] ??
      (
        background: AppColors.surfaceTint,
        foreground: AppColors.primaryStrong,
        label: type.replaceAll('-', ' '),
      );
}

/// The dark-mode counterpart of [_styles] — one tint/ink pair per type.
///
/// The light pastels cannot simply be reused: over a dark card they landed
/// between 1.61:1 and 2.23:1, unreadable. The first fix collapsed all seven into
/// one neutral pill, which was legible but threw the colour coding away — and
/// that coding is what lets a schedule be scanned rather than read.
///
/// So each pair keeps its type's own hue and is rebuilt for a dark ground: the
/// hue darkened and laid on at 32% for the pill, the same hue lightened for the
/// label. Every one clears 4.5:1 on each of the six dark card grounds — the
/// minimum across all of them, not just the lightest: once a coloured tint is
/// laid over them, the lightest ground is not always the worst one for a given
/// label, which is how broadcast and release first shipped at 4.44:1.
/// Locked by `test/app/theme/app_colors_contrast_test.dart`.
const Map<String, TypeStyle> _darkStyles = {
  'concert': (
    background: Color(0x522482A8),
    foreground: Color(0xFF95D4ED),
    label: 'Concert',
  ),
  'broadcast': (
    background: Color(0x52A82457),
    foreground: Color(0xFFF59FC0),
    label: 'Broadcast',
  ),
  'fanmeeting': (
    background: Color(0x522B93A1),
    foreground: Color(0xFF9CDCE5),
    label: 'Fan Meeting',
  ),
  'release': (
    background: Color(0x52A82459),
    foreground: Color(0xFFF59FC1),
    label: 'Release',
  ),
  'event': (
    background: Color(0x52335999),
    foreground: Color(0xFFA6BDE5),
    label: 'Event',
  ),
  'award': (
    background: Color(0x52A87124),
    foreground: Color(0xFFF1C483),
    label: 'Award',
  ),
  'showcase': (
    background: Color(0x522D9F73),
    foreground: Color(0xFF9BE3C7),
    label: 'Showcase',
  ),
};

/// The dark pairs, exposed so the contrast test can assert every one of them.
@visibleForTesting
Map<String, TypeStyle> get darkTypeBadgeStyles => _darkStyles;

/// The tint, ink and label for [type] on a surface of the given [brightness].
///
/// A type with no dark pair of its own — the calendar's `weverse`, `social`,
/// `ambassador` and the vocabularies Awards and Voting bring — falls back to the
/// neutral dark pill, exactly as the light side falls back to the neutral tint.
TypeStyle typeStyleForBrightness(String? type, Brightness brightness) {
  final light = typeStyleFor(type);
  if (brightness == Brightness.light) return light;

  final dark = type == null ? null : _darkStyles[type.toLowerCase()];
  if (dark != null) return dark;

  return (
    background: AppColors.darkSurfaceTint,
    foreground: AppColors.darkInk,
    label: light.label,
  );
}

/// Just the display label for [type] — for callers that need the words without
/// the pill (e.g. Home's "Up next" fallback when an event has no location).
String typeLabelFor(String? type) => typeStyleFor(type).label;

/// A small pill label for a type or status — an event's `type`, an award's, a
/// voting campaign's state.
///
/// `type` stays a free String at the domain level (docs/specs/schedule.md
/// Evolution Notes: String → enum later).
class TypeBadge extends StatelessWidget {
  const TypeBadge({super.key, required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = typeStyleForBrightness(type, theme.brightness);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: AppRadius.pillRadius,
      ),
      // Uppercasing the string itself (Flutter has no `text-transform`) would
      // otherwise make some screen readers spell the pill out letter by letter.
      child: Semantics(
        label: style.label,
        child: ExcludeSemantics(
          child: Text(
            style.label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: style.foreground,
              fontSize: 9.5,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ),
    );
  }
}
