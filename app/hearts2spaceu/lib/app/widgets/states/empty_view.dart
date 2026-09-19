import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import 'loading_view.dart';

/// Shared "empty" state — a soft icon in a tinted circle plus a message.
///
/// Default is a full-page state (large icon, generous padding). [compact]
/// renders an inline row sized to [LoadingView.inlineContentHeight] for small
/// slots (e.g. Home's "Up next"), keeping every state the same height.
class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    this.message = 'Nothing to show yet.',
    this.icon = Icons.inbox_rounded,
    this.compact = false,
  });

  final String message;
  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (compact) {
      return SizedBox(
        height: LoadingView.inlineContentHeight,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                message,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.inkSoftOf(context),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.inkSoftOf(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
