import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/cards/app_card.dart';
import '../../../../app/widgets/cards/capability_card.dart';
import '../../domain/official_platform.dart';

/// One official channel — tapping it leaves the app.
///
/// Design System V2 gives each category its own gradient tile, so the list is
/// scannable by color the way the rest of the app is. The trailing "open in new"
/// icon is the honest signal that this navigates somewhere external rather than
/// to another screen (unlike every other card in the app, which uses a chevron).
class PlatformCard extends StatelessWidget {
  const PlatformCard({super.key, required this.platform, this.onTap});

  final OfficialPlatform platform;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          IconTile(
            icon: _iconFor(platform.category),
            gradient: _gradientFor(platform.category),
            size: 42,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  platform.name,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (platform.handle case final handle?)
                  Text(
                    handle,
                    style: textTheme.labelSmall?.copyWith(
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
          const SizedBox(width: AppSpacing.sm),
          const Icon(
            Icons.open_in_new_rounded,
            size: 18,
            color: AppColors.navIdle,
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

  static List<Color> _gradientFor(String category) {
    switch (category) {
      case 'music':
        return CapabilityGradients.music;
      case 'video':
        return CapabilityGradients.statistics;
      case 'social':
        return CapabilityGradients.members;
      case 'community':
        return CapabilityGradients.updates;
      default:
        return AppColors.heroGradient;
    }
  }
}
