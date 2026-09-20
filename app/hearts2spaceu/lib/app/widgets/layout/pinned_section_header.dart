import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../glass/glass_surface.dart';
import 'section_header.dart';

/// A section heading that stays put while its own section scrolls past it.
///
/// Used by the Schedule's months and the Awards' years. Extracted at the second
/// use rather than the third, against the usual rule, because the copy had
/// already drifted and taken two faults with it: a height that could not grow
/// with the text, and a background painted in `scaffoldBackgroundColor` — which
/// is transparent app-wide since the ambient wash arrived, so cards scrolled
/// under it in plain sight. One of them blurred; the other did not.
///
/// The height is computed from the type it draws, not fixed, and travels with
/// the delegate so a text-size change while the screen is open rebuilds it.
/// Without that Flutter rejects the header's geometry outright.
SliverPersistentHeader pinnedSectionHeader(BuildContext context, String label) {
  final style = Theme.of(context).textTheme.titleMedium!;
  return SliverPersistentHeader(
    pinned: true,
    delegate: _PinnedSectionHeaderDelegate(
      label: label,
      height: AppTypography.linesHeight(context, style, 1) + AppSpacing.md,
    ),
  );
}

class _PinnedSectionHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _PinnedSectionHeaderDelegate({
    required this.label,
    required this.height,
  });

  final String label;
  final double height;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    // Blurred, not filled: a pinned header floats above the list, and the
    // ambient wash leaves no opaque colour to fill it with. The blur is what
    // keeps cards from reading through as they slide underneath.
    return GlassSurface(
      borderRadius: BorderRadius.zero,
      border: false,
      blur: 18,
      child: Container(
        height: height,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
        ),
        child: SectionHeader(label: label),
      ),
    );
  }

  @override
  bool shouldRebuild(_PinnedSectionHeaderDelegate oldDelegate) =>
      oldDelegate.label != label || oldDelegate.height != height;
}
