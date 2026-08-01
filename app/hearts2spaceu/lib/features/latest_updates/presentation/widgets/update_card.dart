import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/badges/type_badge.dart';
import '../../../../app/widgets/cards/app_card.dart';
import '../../domain/update.dart';
import '../update_date_format.dart';

/// A single update — category pill and date on one line, then the headline and
/// its teaser.
///
/// Design System V2 drops the chevron: the whole card is the tap target, and the
/// pill/date line is what the eye uses to place the item in time.
///
/// Built from generic Design System blocks ([AppCard], [TypeBadge]); lives here
/// because it depends on the [Update] domain entity.
class UpdateCard extends StatelessWidget {
  const UpdateCard({super.key, required this.update, this.onTap});

  final Update update;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (update.category case final category?)
                TypeBadge(type: category),
              const Spacer(),
              Text(
                formatPublishedDate(update.publishedAt),
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.inkMuted,
                  letterSpacing: 0,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            update.title,
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          if (update.summary case final summary?) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              summary,
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.inkSoft,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
