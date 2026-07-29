import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';

/// One headline number with its label underneath.
///
/// Deliberately plain: the number is the content, so nothing competes with it.
class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$value',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          // Two lines is enough for every label used here; more would make the
          // tiles in a row different heights.
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
