import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../domain/album.dart';
import 'remote_image.dart';

/// An album — cover flush to the top of the glass card, title and count below.
///
/// Design System V2: the cover is *inside* the card rather than floating above
/// its own caption, so the whole tile reads as one object.
class AlbumCard extends StatelessWidget {
  const AlbumCard({super.key, required this.album, this.onTap});

  final Album album;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadius.lgRadius,
        boxShadow: AppShadows.sm,
      ),
      child: Material(
        color: isDark ? AppColors.darkGlass : AppColors.glass,
        borderRadius: AppRadius.lgRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Expanded, not a fixed height: the cover takes whatever the grid
              // cell leaves after the text, so the card can never overflow no
              // matter what childAspectRatio or text scale is in play.
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  child: RemoteImage(url: album.coverUrl),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      album.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      album.year != null
                          ? '${album.year} · ${album.photos.length} photos'
                          : '${album.photos.length} photos',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.inkMuted,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
