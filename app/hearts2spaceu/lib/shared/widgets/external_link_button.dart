import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/widgets/buttons/secondary_button.dart';
import '../services/url_opener.dart';

/// A button that takes the user to an official page outside the app.
///
/// Lives in `shared/widgets/` rather than `app/widgets/`: it composes a
/// design-system button with the [UrlOpener] service, so it is more than a
/// pure presentational widget while still knowing nothing about any feature's
/// domain.
///
/// Used by the Update, Event, and Member detail pages — one place to get the
/// launch call and the failure message right.
class ExternalLinkButton extends ConsumerWidget {
  const ExternalLinkButton({super.key, required this.url, required this.label});

  final String url;
  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SecondaryButton(
      label: label,
      icon: Icons.open_in_new_rounded,
      onPressed: () => _open(context, ref),
    );
  }

  Future<void> _open(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final opened = await ref.read(urlOpenerProvider).open(url);

    if (!opened) {
      // Say something rather than appearing to ignore the tap.
      messenger.showSnackBar(
        const SnackBar(content: Text("Couldn't open that link.")),
      );
    }
  }
}
