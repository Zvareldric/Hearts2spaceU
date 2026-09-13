import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// A network image that degrades gracefully.
///
/// Third-party URLs die; when one does, only this tile shows a placeholder
/// instead of the page breaking (docs/specs/gallery.md §8).
class RemoteImage extends StatelessWidget {
  const RemoteImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.fallback,
    this.semanticLabel,
  });

  final String url;
  final BoxFit fit;

  /// What to show while loading and after a failure. Defaults to a tinted box
  /// with a broken-image glyph; callers with something better to show — a
  /// release cover falls back to the brand gradient — pass their own.
  final Widget? fallback;

  /// Spoken description for meaningful images. Leave null only when the caller
  /// deliberately treats the image as decorative.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final placeholder = fallback ?? const _DefaultFallback();

    final image = Image.network(
      url,
      fit: fit,
      semanticLabel: semanticLabel,
      // frameBuilder, not loadingBuilder: loadingBuilder reports
      // `progress == null` both when the load is finished *and* before the
      // first chunk arrives, so keying off it renders an empty image for the
      // whole connect phase — a request that hangs shows a blank box forever.
      // frameBuilder's `frame == null` means precisely "no frame decoded yet".
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) return child;
        return placeholder;
      },
      errorBuilder: (context, error, stackTrace) => placeholder,
    );

    return semanticLabel == null
        ? image
        : Semantics(label: semanticLabel, image: true, child: image);
  }
}

class _DefaultFallback extends StatelessWidget {
  const _DefaultFallback();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surfaceTint,
      child: Center(
        child: Icon(
          Icons.broken_image_rounded,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          size: 28,
        ),
      ),
    );
  }
}
