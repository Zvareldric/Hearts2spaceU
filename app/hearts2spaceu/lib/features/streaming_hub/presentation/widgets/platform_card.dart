import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/cards/app_card.dart';
import '../../domain/official_platform.dart';

/// One official channel — tapping it leaves the app.
///
/// The trailing "open in new" icon is the honest signal that this navigates
/// somewhere external rather than to another screen (unlike every other card
/// in the app, which uses a chevron).
class PlatformCard extends StatelessWidget {
  const PlatformCard({super.key, required this.platform, this.onTap});

  final OfficialPlatform platform;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.surfaceTint,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _iconFor(platform.category),
              color: AppColors.primaryStrong,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  platform.name,
                  style: textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (platform.handle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    platform.handle!,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.inkMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const Icon(
            Icons.open_in_new_rounded,
            size: 20,
            color: AppColors.inkMuted,
          ),
        ],
      ),
    );
  }

  /// Category icons, not brand logos: Material ships none, and bundling real
  /// logos brings trademark terms the project has not reviewed.
  static IconData _iconFor(String category) {
    switch (category) {
      case 'music':
        return Icons.library_music_rounded;
      case 'video':
        return Icons.smart_display_rounded;
      case 'social':
        return Icons.alternate_email_rounded;
      case 'community':
        return Icons.forum_rounded;
      default:
        return Icons.link_rounded;
    }
  }
}
