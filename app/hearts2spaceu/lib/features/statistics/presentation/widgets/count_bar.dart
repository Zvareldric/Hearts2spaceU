import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_motion.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';

/// A label and its count on one line, with a proportional bar underneath.
///
/// Design System V2 stacks them rather than putting label | bar | count in a
/// row: the bar gets the full width, so the difference between two years is
/// visible instead of squeezed into the middle third.
///
/// The bar is a plain [AnimatedFractionallySizedBox] — a charting package would
/// be a whole dependency for one rectangle (docs/specs/statistics.md §5).
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Guard against a zero scale; also keeps a lone entry from rendering as an
    // invisible sliver rather than a full bar.
    final fraction = max <= 0 ? 0.0 : (count / max).clamp(0.0, 1.0);

    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.inkSoft,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$count',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.inkMuted,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Container(
            height: _barHeight,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.25),
              borderRadius: AppRadius.pillRadius,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: AnimatedFractionallySizedBox(
                duration: AppMotion.of(context, AppMotion.slow),
                curve: AppMotion.enter,
                widthFactor: fraction,
                // heightFactor is required, not decoration: without it the
                // child's height constraint stays loose, a DecoratedBox with no
                // child collapses to zero height, and the fill vanishes —
                // leaving every bar looking identically full.
                heightFactor: 1,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: AppColors.heroGradient),
                    borderRadius: BorderRadius.all(
                      Radius.circular(AppRadius.pill),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return content;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.smRadius,
      child: content,
    );
  }
}
