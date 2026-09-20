import 'package:flutter/material.dart';

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
    // A title, not an overline. Small uppercase text with wide tracking is the
    // most decorative way to label a section and the least legible; a plain
    // bold line in the reading case says the same thing louder and quieter at
    // once.
    return Text(
      label,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: color ?? Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}
