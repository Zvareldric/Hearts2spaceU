import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';

/// A small pill label for an event's `type` (e.g. "concert", "broadcast").
///
/// `type` stays a free String at the domain level (docs/specs/schedule.md
/// Evolution Notes: String → enum later); this widget only maps known values
/// to a tint for now and falls back gracefully for unknown ones.
class TypeBadge extends StatelessWidget {
  const TypeBadge({super.key, required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = _backgroundFor(type);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.pillRadius,
      ),
      child: Text(
        type,
        style: theme.textTheme.labelSmall?.copyWith(color: AppColors.ink),
      ),
    );
  }

  static Color _backgroundFor(String type) {
    switch (type.toLowerCase()) {
      case 'concert':
        return AppColors.badgeConcertBg;
      case 'broadcast':
        return AppColors.badgeBroadcastBg;
      case 'showcase':
        return AppColors.badgeShowcaseBg;
      case 'fanmeeting':
        return AppColors.badgeFanmeetingBg;
      default:
        return AppColors.surfaceTint;
    }
  }
}
