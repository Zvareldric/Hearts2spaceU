import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../gallery/presentation/widgets/remote_image.dart';
import '../../domain/release.dart';

/// A release's cover art, or a branded placeholder when there is none.
///
/// Reuses the gallery's [RemoteImage] — the loading and error handling for a
/// remote image is already solved there, and covers come from the same kind of
/// URL.
class ReleaseCover extends StatelessWidget {
  const ReleaseCover({
    super.key,
    required this.release,
    this.size,
    this.radius = AppRadius.md,
  });

  final Release release;

  /// Square side length. Null fills whatever the parent gives it.
  final double? size;

  final double radius;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: switch (release.coverUrl) {
          // The same placeholder covers three cases — no URL on file, still
          // loading, and a dead URL — so a cover slot is never an empty hole,
          // which matters most offline where none of them resolve.
          final url? => RemoteImage(
            url: url,
            fallback: const _CoverPlaceholder(),
          ),
          _ => const _CoverPlaceholder(),
        },
      ),
    );
  }
}

/// Stands in for cover art: the brand gradient with an album glyph, rather than
/// the generic broken-image tile — a sleeve that failed to load should still
/// look like a sleeve.
class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.heroGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(Icons.album_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}
