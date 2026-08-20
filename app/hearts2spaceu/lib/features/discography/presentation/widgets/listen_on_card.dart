import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/cards/app_card.dart';
import '../../../../routes/app_routes.dart';

/// The way from Music into the official channels.
///
/// Sends the user to the platforms the app already knows about, rather than
/// storing a per-release link the Product Owner would have to maintain seven
/// times over. Shared by the Music screen and every release detail, so the
/// wording and the destination cannot drift apart between the two.
class ListenOnCard extends StatelessWidget {
  const ListenOnCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.streamingHub),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.headphones_rounded,
            color: AppColors.primaryStrong,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Listen on official platforms',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
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
