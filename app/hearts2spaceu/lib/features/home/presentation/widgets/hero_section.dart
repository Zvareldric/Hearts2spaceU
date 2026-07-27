import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';

/// Home's hero — brand identity + a time-aware greeting.
///
/// Full-bleed (edge-to-edge within the responsive column) and reaches the
/// very top of the screen behind the status bar/notch; only its *content*
/// respects the safe-area inset via padding (docs/specs/home-layout.md §2).
/// Replaces the standard AppBar on Home — this is Home's only identity chrome.
class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topInset = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        topInset + AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xxl,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.heroGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.xl),
          bottomRight: Radius.circular(AppRadius.xl),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _greeting(DateTime.now()),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.inkMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              const _BrandMark(),
              const SizedBox(width: AppSpacing.sm),
              Text('Hearts2spaceU', style: theme.textTheme.displaySmall),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Your Hearts2Hearts companion',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.inkMuted,
            ),
          ),
        ],
      ),
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

/// Small placeholder brand mark (no final logo asset yet) — a heart icon in a
/// soft circle, alluding to "Hearts2Hearts" without adding any dependency.
class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        boxShadow: AppShadows.sm,
      ),
      child: const Icon(
        Icons.favorite_rounded,
        color: AppColors.primaryStrong,
        size: 18,
      ),
    );
  }
}
