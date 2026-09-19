import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/badges/type_badge.dart';
import '../../../../app/widgets/cards/app_card.dart';
import '../../domain/award.dart';

/// One achievement in the list.
///
/// Deliberately shows no date: the year heading above already provides it, and
/// most entries have nothing more precise than a year (docs/specs/awards.md §4).
class AwardCard extends StatelessWidget {
  const AwardCard({super.key, required this.award, this.onTap});

  final Award award;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final subtitle = _subtitle(award);

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _iconFor(award.type),
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (award.type != Award.typeAward) ...[
                  TypeBadge(type: award.type),
                  const SizedBox(height: AppSpacing.sm),
                ],
                Text(award.title, style: textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  /// Who gave it, plus the work or the members when that is what distinguishes
  /// this entry from its neighbours.
  static String _subtitle(Award award) {
    final parts = <String>[
      award.ceremony,
      if (award.work != null) award.work!,
      if (award.isIndividual) award.members.join(', '),
    ];
    return parts.join(' · ');
  }

  static IconData _iconFor(String type) {
    switch (type) {
      case Award.typeMusicShow:
        return Icons.music_note_rounded;
      case Award.typeMilestone:
        return Icons.workspace_premium_rounded;
      default:
        return Icons.emoji_events_rounded;
    }
  }
}
