import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/badges/type_badge.dart';
import '../../../../app/widgets/cards/app_card.dart';
import '../../domain/event.dart';

/// Design System V1 event card — prominent date, title, and a [TypeBadge].
///
/// Built from generic Design System building blocks ([AppCard], [TypeBadge]);
/// lives here (not in `app/widgets/`) because it depends on the [Event]
/// domain entity — `app/` must never know about a feature's domain
/// (Checkpoint 2.5 cleanup).
///
/// Staged, not yet wired: `schedule_page.dart` still renders the older
/// `EventCard` (`ListTile`-based) below. This becomes the real `EventCard` —
/// replacing that file — at the **Schedule Refresh** checkpoint.
class EventCardRefresh extends StatelessWidget {
  const EventCardRefresh({super.key, required this.event, this.onTap});

  final Event event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final start = event.startDateTime;

    return AppCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DateBlock(day: start.day, month: _monthAbbrev(start.month)),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (event.type != null) ...[
                  TypeBadge(type: event.type!),
                  const SizedBox(height: AppSpacing.sm),
                ],
                Text(event.title, style: textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _timeAndLocation(event),
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.inkMuted),
        ],
      ),
    );
  }

  static String _timeAndLocation(Event event) {
    final hour = event.startDateTime.hour.toString().padLeft(2, '0');
    final minute = event.startDateTime.minute.toString().padLeft(2, '0');
    final time = '$hour:$minute';
    return event.location == null ? time : '$time · ${event.location}';
  }

  static String _monthAbbrev(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}

/// The prominent day/month block on the left of an [EventCardRefresh].
class _DateBlock extends StatelessWidget {
  const _DateBlock({required this.day, required this.month});

  final int day;
  final String month;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceTint,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            '$day',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.primaryStrong,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            month.toUpperCase(),
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppColors.inkMuted),
          ),
        ],
      ),
    );
  }
}
