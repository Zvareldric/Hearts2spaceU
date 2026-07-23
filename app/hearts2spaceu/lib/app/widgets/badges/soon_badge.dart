import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';

/// A small neutral pill marking something as not yet available.
///
/// Same pill shape as [TypeBadge], but always a muted neutral tint (not
/// per-category color) — used by [ComingSoonCard] and reusable wherever a
/// "not active yet" marker is needed.
class SoonBadge extends StatelessWidget {
  const SoonBadge({super.key, this.label = 'Soon'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceTint,
        borderRadius: AppRadius.pillRadius,
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: AppColors.inkMuted),
      ),
    );
  }
}
