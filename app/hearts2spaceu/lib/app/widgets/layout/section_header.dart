import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// A small overline-style label introducing a section (e.g. "Up next").
///
/// Generic and domain-agnostic — just renders a String, uppercased, in the
/// `labelSmall` role (Design System V1). Callers pass natural-case text.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.label, this.color});

  final String label;

  /// Overrides the muted default — for a header sitting on a tinted card, where
  /// the muted grey loses contrast against the fill.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(
        context,
      ).textTheme.labelSmall?.copyWith(color: color ?? AppColors.inkMuted),
    );
  }
}
