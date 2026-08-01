import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/cards/app_card.dart';
import '../../../latest_updates/domain/update.dart';

/// Home's lead card: the newest update, tinted so it outranks everything below.
///
/// Lives here (not `app/widgets/`) because it depends on the [Update] domain
/// entity — `app/` must never know a feature's domain (Checkpoint 2.5).
class HeroUpdateCard extends StatelessWidget {
  const HeroUpdateCard({super.key, required this.update, this.onTap});

  final Update update;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.xl),
      gradient: LinearGradient(
        colors: [
          AppColors.primary.withValues(alpha: 0.55),
          AppColors.secondary.withValues(alpha: 0.55),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _CategoryPill(label: update.category ?? 'Update'),
          const SizedBox(height: AppSpacing.sm),
          Text(
            update.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (update.summary case final summary?) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              summary,
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.inkSoft,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          // Decoration, not a second tap target: the whole card is already the
          // button, and nesting one inside it would give touch users two
          // overlapping targets for the same action.
          const _ReadMoreAffordance(),
        ],
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.60),
        borderRadius: AppRadius.pillRadius,
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: AppColors.primaryStrong),
      ),
    );
  }
}

class _ReadMoreAffordance extends StatelessWidget {
  const _ReadMoreAffordance();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: AppRadius.pillRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Read more',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          const Icon(
            Icons.chevron_right_rounded,
            color: Colors.white,
            size: 16,
          ),
        ],
      ),
    );
  }
}
