import 'package:flutter/material.dart';

/// Shown while an async operation is in progress.
///
/// Duplicated per the **Rule of Three** (2nd use in the app) — promote to
/// `lib/shared/widgets/` only on the 3rd reuse.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
