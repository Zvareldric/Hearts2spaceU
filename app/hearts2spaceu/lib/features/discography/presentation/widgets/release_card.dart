import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/cards/app_card.dart';
import '../../domain/release.dart';
import '../release_format.dart';
import 'release_cover.dart';

/// One release in the Discography list — cover, title, format and date, and how
/// many tracks are on file.
///
/// A list row rather than a grid tile on purpose: Gallery already owns the
/// two-column cover grid, and a second one would read as the same screen.
class ReleaseCard extends StatelessWidget {
  const ReleaseCard({super.key, required this.release, this.onTap});

  final Release release;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final trackCount = release.tracks.length;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Hero(
            tag: 'release-cover-${release.id}',
            child: ReleaseCover(release: release, size: 64),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  release.title,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  formatReleaseMeta(release),
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.inkMuted,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // Only when there is something to count: "0 tracks" would read
                // as a release with no songs rather than one not yet curated.
                if (trackCount > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    trackCount == 1 ? '1 track' : '$trackCount tracks',
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.primaryStrong,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.navIdle,
            size: 20,
          ),
        ],
      ),
    );
  }
}
