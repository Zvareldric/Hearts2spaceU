import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import 'app_card.dart';

/// A tappable entry point to a capability (e.g. "Members", "Schedule").
///
/// Generic and domain-agnostic — an icon tile, a title, and a subtitle. Used by
/// the More menu; Home's four quick actions are a tighter, icon-only variant.
class CapabilityCard extends StatelessWidget {
  const CapabilityCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.gradient = AppColors.heroGradient,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  /// The icon tile's fill. Each capability gets its own pastel pair so the menu
  /// is scannable by color, not just by reading every label.
  final List<Color> gradient;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          IconTile(icon: icon, gradient: gradient),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: textTheme.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: textTheme.labelMedium?.copyWith(color: AppColors.inkMuted),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// The rounded-square gradient icon chip used by [CapabilityCard] and Home's
/// quick actions — the one place the icon-on-gradient recipe is defined.
class IconTile extends StatelessWidget {
  const IconTile({
    super.key,
    required this.icon,
    required this.gradient,
    this.size = 40,
  });

  final IconData icon;
  final List<Color> gradient;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size / 3),
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.45),
    );
  }
}

/// The pastel pairs used across the capability entry points, so Home's quick
/// actions and the More menu tint the same capability identically.
class CapabilityGradients {
  const CapabilityGradients._();

  static const List<Color> members = [Color(0xFF87CEEB), Color(0xFF4FA3D1)];
  static const List<Color> music = [Color(0xFFF8AFCB), Color(0xFFF090B5)];
  static const List<Color> discography = [Color(0xFFFFC9A8), Color(0xFFF0906B)];
  static const List<Color> statistics = [Color(0xFFC6D9FF), Color(0xFF9DAEEE)];
  static const List<Color> updates = [Color(0xFFFFD6E8), Color(0xFFEE9EC2)];
  static const List<Color> awards = [Color(0xFFFFE0B4), Color(0xFFE8B65C)];
  static const List<Color> voting = [Color(0xFFC6EFDF), Color(0xFF6FC2A6)];
}
