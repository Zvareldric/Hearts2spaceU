import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

/// Lays [children] out two to a row, each row as tall as its tallest child.
///
/// The replacement for a two-column `GridView` with a fixed `childAspectRatio`.
/// A cell in such a grid takes its height from its width, so it cannot grow
/// when the text inside it does — and every one of the three screens built that
/// way broke: More at 390dp and Statistics at 360dp, both at normal text size,
/// and Members at 200% text. Each carried a comment promising headroom for
/// large text that the arithmetic never had.
///
/// Here a row measures its children first. Both cards in a row stretch to the
/// taller one, so the layout keeps its even rhythm, and every row grows with
/// its text instead of clipping it. An odd last child keeps its half width.
///
/// Not lazy: every child is built. That is right for a menu or a roster of a
/// dozen tiles; a list of hundreds wants a sliver instead.
class PairedRows extends StatelessWidget {
  const PairedRows({
    super.key,
    required this.children,
    this.spacing = AppSpacing.md,
  });

  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < children.length; i += 2) ...[
          if (i > 0) SizedBox(height: spacing),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: children[i]),
                SizedBox(width: spacing),
                Expanded(
                  child: i + 1 < children.length
                      ? children[i + 1]
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
