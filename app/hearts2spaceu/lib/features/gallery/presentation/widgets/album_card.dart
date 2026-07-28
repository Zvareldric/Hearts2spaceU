import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../domain/album.dart';
import 'remote_image.dart';

/// An album, shown as its cover with the title underneath.
class AlbumCard extends StatelessWidget {
  const AlbumCard({super.key, required this.album, this.onTap});

  final Album album;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      borderRadius: AppRadius.lgRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.lgRadius,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: AppRadius.lgRadius,
              child: DecoratedBox(
                decoration: BoxDecoration(boxShadow: AppShadows.sm),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: RemoteImage(url: album.coverUrl),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              album.title,
              style: textTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              album.year != null
                  ? '${album.year} · ${album.photos.length} photos'
                  : '${album.photos.length} photos',
              style: textTheme.bodyMedium?.copyWith(color: AppColors.inkMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
