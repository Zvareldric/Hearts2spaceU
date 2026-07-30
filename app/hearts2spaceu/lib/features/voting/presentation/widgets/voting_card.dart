import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/badges/type_badge.dart';
import '../../../../app/widgets/cards/app_card.dart';
import '../../domain/voting_campaign.dart';

/// One vote, with how long is left to act on it.
class VotingCard extends StatelessWidget {
  const VotingCard({
    super.key,
    required this.campaign,
    required this.now,
    this.onTap,
  });

  final VotingCampaign campaign;
  final DateTime now;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final upcoming = campaign.isUpcomingAt(now);

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.surfaceTint,
              shape: BoxShape.circle,
            ),
            child: Icon(
              upcoming ? Icons.schedule_rounded : Icons.how_to_vote_rounded,
              color: AppColors.primaryStrong,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Only upcoming votes are badged: an open vote is the normal
                // case, and badging every card would just be noise.
                if (upcoming) ...[
                  const TypeBadge(type: 'upcoming'),
                  const SizedBox(height: AppSpacing.sm),
                ],
                Text(
                  campaign.title,
                  style: textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _subtitle(campaign, now),
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.inkMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            upcoming
                ? Icons.hourglass_empty_rounded
                : Icons.open_in_new_rounded,
            size: 20,
            color: AppColors.inkMuted,
          ),
        ],
      ),
    );
  }

  static String _subtitle(VotingCampaign campaign, DateTime now) {
    final when = campaign.isUpcomingAt(now)
        ? 'Opens ${formatRemaining(campaign.opensAt!.difference(now))}'
        : 'Closes ${formatRemaining(campaign.closesAt.difference(now))}';
    return '${campaign.organizer} · $when';
  }
}

/// Turns a duration into a short human phrase, e.g. `in 3 days`.
///
/// Presentation-only: the domain keeps raw [DateTime]s.
String formatRemaining(Duration left) {
  if (left.isNegative) return 'now';
  if (left.inDays >= 1) {
    return 'in ${left.inDays} ${left.inDays == 1 ? 'day' : 'days'}';
  }
  if (left.inHours >= 1) {
    return 'in ${left.inHours} ${left.inHours == 1 ? 'hour' : 'hours'}';
  }
  if (left.inMinutes >= 1) {
    return 'in ${left.inMinutes} min';
  }
  return 'very soon';
}
