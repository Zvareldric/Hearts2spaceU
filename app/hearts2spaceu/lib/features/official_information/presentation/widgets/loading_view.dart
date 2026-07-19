import 'package:flutter/material.dart';

/// Shown while an async operation is in progress.
///
/// Kept generic (no feature-specific text) so it can be reused across the app;
/// promote to `lib/shared/widgets/` once a second feature needs it.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
