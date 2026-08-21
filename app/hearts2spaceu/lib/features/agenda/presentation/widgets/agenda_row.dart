import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/badges/type_badge.dart';
import '../../../../app/widgets/cards/app_card.dart';
import '../../../collection/domain/favorite.dart';
import '../../../collection/presentation/widgets/favorite_button.dart';
import '../../../schedule/presentation/event_date_format.dart';
// For `formatRemaining`: one phrase for "how long is left", written once, so a
// countdown never reads differently here than it does on the Voting Hub.
import '../../../voting/presentation/widgets/voting_card.dart';
import '../../domain/agenda_item.dart';

/// One agenda row — an event or a vote, told apart at a glance.
///
/// Built from the shared building blocks ([AppCard], [TypeBadge],
/// [FavoriteButton]) and lives in the feature, not in `app/widgets/`, because
/// it knows what an [AgendaItem] is.
class AgendaRow extends StatelessWidget {
  const AgendaRow({
    super.key,
    required this.item,
    required this.now,
    this.onTap,
  });

  final AgendaItem item;

  /// The instant the whole list is measured against, passed in so every row
  /// counts down from the same moment.
  final DateTime now;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isVote = item.kind == AgendaKind.vote;
    final meta = _meta(item);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
      ),
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
            child: Icon(_icon(item), color: AppColors.primaryStrong, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // `vote` is not in the badge's type map, and does not need to
                // be: an unmapped type still renders as its own word
                // (docs/design-system-v2.md §10). A vote that has not opened
                // says so beside it, so it can never read as already running.
                if (isVote) ...[
                  Row(
                    children: [
                      const TypeBadge(type: 'vote'),
                      if (item.isUpcomingVote) ...[
                        const SizedBox(width: AppSpacing.sm),
                        const TypeBadge(type: 'upcoming'),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                ],
                Text(
                  item.title,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (meta.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    meta,
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.inkMuted,
                      letterSpacing: 0,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: AppSpacing.xs),
                Text(
                  agendaDueLabel(item, now),
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.primaryStrong,
                    letterSpacing: 0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // An event can be kept; a vote cannot — one that is marked would
          // vanish from the collection the moment it closed
          // (docs/specs/agenda.md §4). So a vote's end of the row shows where
          // tapping leads instead.
          if (isVote)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Icon(
                item.isUpcomingVote
                    ? Icons.hourglass_empty_rounded
                    : Icons.open_in_new_rounded,
                size: 20,
                color: AppColors.inkMuted,
              ),
            )
          else
            FavoriteButton(type: Favorite.typeEvent, id: item.id),
        ],
      ),
    );
  }

  static IconData _icon(AgendaItem item) => switch (item.kind) {
    AgendaKind.vote =>
      item.isUpcomingVote ? Icons.schedule_rounded : Icons.how_to_vote_rounded,
    AgendaKind.event => Icons.event_rounded,
  };

  /// The line of context under the title: when and where an event is, or who
  /// runs a vote. An all-day event prints no time at all — the source only
  /// gave a date (docs/specs/schedule.md §4).
  static String _meta(AgendaItem item) {
    final parts = <String>[
      if (item.kind == AgendaKind.event)
        formatEventDateTime(item.dueAt, allDay: item.isAllDay),
      if (item.subtitle case final subtitle? when subtitle.isNotEmpty) subtitle,
    ];
    return parts.join(' · ');
  }
}

/// How long is left, in the words that fit what the deadline means.
///
/// The two kinds share one time axis but not one sentence: an event's date is
/// when it **starts**, so "in 3 days" is the truth; a vote's is when it
/// **ends**, and "in 3 days" would read as "voting opens in 3 days" — the exact
/// opposite. This is the biggest honesty risk in merging the two lists, so it
/// is stated in one place and locked by a test (docs/specs/agenda.md §4).
///
/// A vote that has not opened yet still counts down to its close: that is the
/// deadline the row is sorted by, and the badge beside it says it is upcoming.
String agendaDueLabel(AgendaItem item, DateTime now) {
  final left = formatRemaining(item.dueAt.difference(now));
  return switch (item.kind) {
    AgendaKind.vote => 'Closes $left',
    AgendaKind.event => left,
  };
}
