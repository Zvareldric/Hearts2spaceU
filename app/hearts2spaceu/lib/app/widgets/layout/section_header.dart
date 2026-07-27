import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// A small overline-style label introducing a section (e.g. "Up next").
///
/// Generic and domain-agnostic — just renders a String, uppercased, in the
/// `labelSmall` role (Design System V1). Callers pass natural-case text.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(
        context,
      ).textTheme.labelSmall?.copyWith(color: AppColors.inkMuted),
    );
  }
}
