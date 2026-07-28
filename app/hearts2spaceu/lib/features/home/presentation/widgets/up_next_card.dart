import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/cards/app_card.dart';
import '../../../schedule/domain/event.dart';
import '../../../schedule/presentation/event_date_format.dart';

/// A compact teaser for the single nearest upcoming event, shown in Home's
/// "Up next" section. Lighter-weight than Schedule's own list card — this is
/// a preview, not a list item.
///
/// Lives here (not `app/widgets/`) because it depends on the [Event] domain
/// entity (Checkpoint 2.5 rule). Reuses `formatEventDateTime` from the
/// Schedule feature — Home already depends on Schedule's `upcomingEventsProvider`,
/// so this isn't a new category of coupling.
class UpNextCard extends StatelessWidget {
  const UpNextCard({super.key, required this.event, this.onTap});

  final Event event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
            child: const Icon(
              Icons.event_rounded,
              color: AppColors.primaryStrong,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // min: without it the Column fills any bounded height it is
              // given, making the card's height depend on its context.
              mainAxisSize: MainAxisSize.min,
              children: [
                // Single-line: a teaser stays one predictable height, so the
                // slot never grows when a long title arrives.
                Text(
                  event.title,
                  style: textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  formatEventDateTime(
                    event.startDateTime,
                    allDay: event.allDay,
                  ),
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.inkMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.inkMuted),
        ],
      ),
    );
  }
}
