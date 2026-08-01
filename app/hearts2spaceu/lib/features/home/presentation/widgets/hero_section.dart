import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';

/// Home's header — brand identity + a time-aware greeting.
///
/// Design System V2 dropped the full-bleed gradient panel this used to be: the
/// ambient wash now carries the color, so a second gradient here only muddied
/// it. What is left is type on the background, which lets the announcement card
/// below be the first thing the eye lands on.
class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _greeting(DateTime.now()),
          style: theme.textTheme.labelMedium?.copyWith(
            color: AppColors.inkMuted,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            const _BrandMark(),
            const SizedBox(width: AppSpacing.sm),
            // The wordmark must never clip: it is the app's name, on the
            // first screen. scaleDown shrinks it only when the width really
            // demands it and leaves it at full size everywhere else — so no
            // font, text-scale setting, or screen width can cut it off.
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'Hearts2spaceU',
                  maxLines: 1,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Your Hearts2Hearts companion',
          style: theme.textTheme.labelMedium?.copyWith(
            color: AppColors.inkMuted,
          ),
        ),
      ],
    );
  }

  /// Morning &lt;12 · Afternoon &lt;18 · Evening otherwise (docs/specs/home-layout.md §2).
  static String _greeting(DateTime now) {
    final hour = now.hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }
}

/// Small placeholder brand mark (no final logo asset yet) — a heart on the
/// brand gradient, alluding to "Hearts2Hearts" without adding any dependency.
class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.heroGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(11),
        boxShadow: AppShadows.sm,
      ),
      child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 17),
    );
  }
}
