import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/cards/app_card.dart';

/// One headline number with its label underneath, on its own glass tile.
///
/// Design System V2 gives each number its own pane in a 2×2 grid rather than
/// four columns inside one card: at 360dp a four-across row leaves each label
/// about 70px wide.
class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$value',
            style: theme.textTheme.headlineSmall?.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            // Two lines is enough for every label used here; more would make
            // the tiles in a row different heights.
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.inkMuted,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
