import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/badges/type_badge.dart';
import '../../../../app/widgets/cards/app_card.dart';
import '../../../collection/domain/favorite.dart';
import '../../../collection/presentation/widgets/favorite_button.dart';
import '../../domain/event.dart';
import '../event_date_format.dart';
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
    final meta = _timeAndLocation(event);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
      ),
      child: _EventCardBody(event: event, meta: meta),
    );
  }

  /// Time and place, whichever are known. An all-day event has no time to
  /// show, so it falls back to the location — or to nothing at all, in which
  /// case the line is omitted rather than left blank.
  static String _timeAndLocation(Event event) {
    final clock = formatEventClock(event);
    final parts = <String>[
      if (clock.isNotEmpty) clock,
      if (event.location != null) event.location!,
    ];
    return parts.join(' · ');
  }
}

class _EventCardBody extends StatelessWidget {
  const _EventCardBody({required this.event, required this.meta});

  final Event event;
  final String meta;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final details = Column(
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
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (event.type case final type?) TypeBadge(type: type),
            if (meta.isNotEmpty)
              Text(
                meta,
                style: textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  letterSpacing: 0,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ],
    );
    final favorite = FavoriteButton(type: Favorite.typeEvent, id: event.id);
    final scaled = MediaQuery.textScalerOf(context).scale(1);

    if (scaled >= 1.3) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              EventDateBlock(event: event),
              favorite,
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          details,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EventDateBlock(event: event),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: details),
        favorite,
      ],
    );
  }
}
