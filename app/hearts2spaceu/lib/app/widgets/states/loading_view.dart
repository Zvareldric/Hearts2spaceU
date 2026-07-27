import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

/// Shared "loading" state — a centered, brand-colored spinner.
///
/// [compact] renders a smaller spinner sized to [inlineContentHeight], for use
/// inside a small inline slot (e.g. Home's "Up next") rather than a full page.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message, this.compact = false});

  final String? message;
  final bool compact;

  /// Content height shared by every compact state view, so a slot keeps the
  /// same height across loading/empty/error/data and never reflows the page.
  static const double inlineContentHeight = 48;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (compact) {
      return SizedBox(
        height: inlineContentHeight,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: colorScheme.primary,
              strokeWidth: 2.5,
            ),
          ),
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: colorScheme.primary),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(message!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
