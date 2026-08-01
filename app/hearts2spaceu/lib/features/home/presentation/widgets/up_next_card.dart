import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/badges/type_badge.dart';
import '../../../../app/widgets/cards/app_card.dart';
import '../../../../app/widgets/states/loading_view.dart';
import '../../../schedule/domain/event.dart';
import '../../../schedule/presentation/widgets/event_date_block.dart';

/// A compact teaser for the single nearest upcoming event, shown in Home's
/// "Up next" section. Lighter-weight than Schedule's own list card — this is
/// a preview, not a list item.
///
/// Design System V2 shows the date as a tinted block and the place underneath
/// the title, matching the Schedule card it previews, so the two read as the
/// same object in two sizes.
///
/// Lives here (not `app/widgets/`) because it depends on the [Event] domain
/// entity (Checkpoint 2.5 rule).
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
          // 48, matching LoadingView.inlineContentHeight: the date block is the
          // tallest thing in this row, so it alone decides the card's height —
          // and every state of the slot has to come out the same height or the
          // sections below shift when one replaces another
          // (see up_next_slot_height_test.dart).
          EventDateBlock(event: event, size: LoadingView.inlineContentHeight),
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
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  event.location ?? typeLabelFor(event.type),
                  style: textTheme.labelMedium?.copyWith(
                    color: AppColors.inkMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.navIdle,
            size: 20,
          ),
        ],
      ),
    );
  }
}
