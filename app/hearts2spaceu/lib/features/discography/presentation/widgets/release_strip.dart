import 'package:flutter/material.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../domain/release.dart';
import '../release_format.dart';
import 'release_cover.dart';

/// The discography as a horizontal run of covers — Home's browse-by-eye row.
///
/// Covers only, no glass card around them: seven album sleeves side by side are
/// already the most colorful thing on Home, and a pane around each one would
/// fight them.
class ReleaseStrip extends StatelessWidget {
  const ReleaseStrip({
    super.key,
    required this.releases,
    required this.onSelected,
  });

  final List<Release> releases;
  final ValueChanged<Release> onSelected;

  static const _coverSize = 124.0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final titleStyle = textTheme.labelMedium!.copyWith(
      fontWeight: FontWeight.w600,
    );
    final metaStyle = textTheme.labelSmall!.copyWith(
      color: AppColors.inkSoftOf(context),
      letterSpacing: 0,
      fontWeight: FontWeight.w400,
    );
    final lines = AppTypography.maxLines(context, 1);

    // Cover plus its text, fixed for a given text size so the row does not
    // jump as titles of different lengths scroll through it — but computed,
    // not hard-coded. The old constant held two lines at 100% and left 200%
    // text 24px past the bottom of the strip.
    final height =
        _coverSize +
        AppSpacing.sm +
        AppTypography.linesHeight(context, titleStyle, lines) +
        AppTypography.linesHeight(context, metaStyle, lines);

    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        // Lets the covers run to the screen edge while still lining the first
        // one up with the rest of Home's content.
        padding: EdgeInsets.zero,
        clipBehavior: Clip.none,
        itemCount: releases.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final release = releases[index];
          return SizedBox(
            width: _coverSize,
            child: GestureDetector(
              onTap: () => onSelected(release),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'release-cover-${release.id}',
                    child: ReleaseCover(release: release, size: _coverSize),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    release.title,
                    style: titleStyle,
                    maxLines: lines,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    formatReleaseMeta(release),
                    style: metaStyle,
                    maxLines: lines,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
