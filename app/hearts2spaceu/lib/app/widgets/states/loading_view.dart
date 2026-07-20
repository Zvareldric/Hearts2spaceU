import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

/// Shared "loading" state — a centered, brand-colored spinner.
///
/// Kept intentionally simple for V1 (a skeleton/shimmer per card shape is a
/// natural Checkpoint 3–6 evolution once each page's final layout is wired).
/// Not yet used by any page — pages adopt this in their Refresh checkpoint.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
