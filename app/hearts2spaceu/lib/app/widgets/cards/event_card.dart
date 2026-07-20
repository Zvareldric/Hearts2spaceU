import 'package:flutter/material.dart';

import '../../../features/schedule/domain/event.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../badges/type_badge.dart';
import 'app_card.dart';

/// Design System V1 event card — prominent date, title, and a [TypeBadge].
///
/// Lives in `app/widgets/cards/` as a shared design-system component (see the
/// note in `member_card.dart` re: depending on a feature's domain entity).
/// Not yet wired into any page — `schedule` still renders its own local
/// `EventCard` (`ListTile`-based) until the Schedule Refresh checkpoint swaps
/// it in.
class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event, this.onTap});

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

/// The prominent day/month block on the left of an [EventCard].
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
