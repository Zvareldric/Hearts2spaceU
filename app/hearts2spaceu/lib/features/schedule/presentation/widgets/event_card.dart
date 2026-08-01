import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/badges/type_badge.dart';
import '../../../../app/widgets/cards/app_card.dart';
import '../../../collection/domain/favorite.dart';
import '../../../collection/presentation/widgets/favorite_button.dart';
import '../../domain/event.dart';
import 'event_date_block.dart';

/// Design System V2 event card — tinted date block, title, then the type pill
/// and place on one line, with a save button at the end.
///
/// Title before the pill on purpose: the title is what you scan for, so it sits
/// at the top of the row where the eye lands first.
///
/// Built from generic Design System building blocks ([AppCard], [TypeBadge]);
/// lives here (not `app/widgets/`) because it depends on the [Event] domain
/// entity — `app/` must never know about a feature's domain (Checkpoint 2.5).
class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event, this.onTap});

  final Event event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final meta = _timeAndLocation(event);

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
          EventDateBlock(event: event),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  event.title,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    if (event.type case final type?) ...[
                      TypeBadge(type: type),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    if (meta.isNotEmpty)
                      Expanded(
                        child: Text(
                          meta,
                          style: textTheme.labelSmall?.copyWith(
                            color: AppColors.inkMuted,
                            letterSpacing: 0,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Replaces the chevron: tapping the card already opens the detail
          // page, so the row's one affordance is the thing you cannot do from
          // anywhere else — save it. This is what makes Collection's "tap the
          // heart on anything" true from the list, not just the detail page.
          FavoriteButton(type: Favorite.typeEvent, id: event.id),
        ],
      ),
    );
  }

  /// Time and place, whichever are known. An all-day event has no time to
  /// show, so it falls back to the location — or to nothing at all, in which
  /// case the line is omitted rather than left blank.
  static String _timeAndLocation(Event event) {
    final parts = <String>[
      if (!event.allDay)
        '${event.startDateTime.hour.toString().padLeft(2, '0')}'
            ':${event.startDateTime.minute.toString().padLeft(2, '0')}',
      if (event.location != null) event.location!,
    ];
    return parts.join(' · ');
  }
}
