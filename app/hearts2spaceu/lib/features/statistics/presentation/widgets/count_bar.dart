import 'package:flutter/material.dart';

import '../../../../app/theme/app_motion.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';

/// A label, a proportional bar, and a count.
///
/// The bar is a plain [FractionallySizedBox] — a charting package would be a
/// whole dependency for one rectangle (docs/specs/statistics.md §5).
class CountBar extends StatelessWidget {
  const CountBar({
    super.key,
    required this.label,
    required this.count,
    required this.max,
    this.onTap,
  });

  final String label;
  final int count;

  /// The largest count in the group — what the bar is drawn against.
  final int max;

  final VoidCallback? onTap;

  static const _barHeight = 8.0;
  static const _labelWidth = 64.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Guard against a zero scale; also keeps a lone entry from rendering as an
    // invisible sliver rather than a full bar.
    final fraction = max <= 0 ? 0.0 : (count / max).clamp(0.0, 1.0);

    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: _labelWidth,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Container(
              height: _barHeight,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: AppRadius.pillRadius,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AnimatedFractionallySizedBox(
                  duration: AppMotion.of(context, AppMotion.slow),
                  curve: AppMotion.enter,
                  widthFactor: fraction,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: AppRadius.pillRadius,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          SizedBox(
            width: 28,
            child: Text(
              '$count',
              textAlign: TextAlign.right,
              style: theme.textTheme.labelMedium,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return row;

    return InkWell(onTap: onTap, borderRadius: AppRadius.smRadius, child: row);
  }
}
