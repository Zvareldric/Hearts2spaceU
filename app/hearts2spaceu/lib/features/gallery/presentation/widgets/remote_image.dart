import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// A network image that degrades gracefully.
///
/// Third-party URLs die; when one does, only this tile shows a placeholder
/// instead of the page breaking (docs/specs/gallery.md §8).
class RemoteImage extends StatelessWidget {
  const RemoteImage({super.key, required this.url, this.fit = BoxFit.cover});

  final String url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const ColoredBox(
          color: AppColors.surfaceTint,
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => const ColoredBox(
        color: AppColors.surfaceTint,
        child: Center(
          child: Icon(
            Icons.broken_image_rounded,
            color: AppColors.inkMuted,
            size: 28,
          ),
        ),
      ),
    );
  }
}
