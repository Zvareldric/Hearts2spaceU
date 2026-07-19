import 'package:flutter/material.dart';

/// Shown when a successful load returns no items.
///
/// Duplicated per the **Rule of Three** (2nd use in the app).
class EmptyView extends StatelessWidget {
  const EmptyView({super.key, this.message = 'Nothing to show yet.'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}
