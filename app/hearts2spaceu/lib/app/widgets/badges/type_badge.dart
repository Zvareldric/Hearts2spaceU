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
/// Locked by `test/app/theme/app_colors_contrast_test.dart`.
const Map<String, TypeStyle> _styles = {
  'concert': (
    background: Color(0x8C87CEEB),
    foreground: Color(0xFF15597F),
    label: 'Concert',
  ),
  'broadcast': (
    background: Color(0x8CF8AFCB),
    foreground: Color(0xFF9E3563),
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
    foreground: Color(0xFFA83A6B),
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
    foreground: Color(0xFF7D581C),
    label: 'Award',
  ),
  'showcase': (
    background: Color(0x8CC6EFDF),
    foreground: Color(0xFF2F6E58),
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
    final style = typeStyleFor(type);

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
