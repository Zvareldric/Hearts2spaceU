import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/badges/type_badge.dart';
import '../../../../app/widgets/cards/app_card.dart';
import '../../domain/update.dart';
import '../update_date_format.dart';

/// A single update in the list — category badge, headline, and teaser.
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (update.category != null) ...[
                TypeBadge(type: update.category!),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Text(
                  formatPublishedDate(update.publishedAt),
                  style: textTheme.labelMedium?.copyWith(
                    color: AppColors.inkMuted,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.inkMuted,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(update.title, style: textTheme.titleMedium),
          if (update.summary != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              update.summary!,
              style: textTheme.bodyMedium?.copyWith(color: AppColors.inkMuted),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
