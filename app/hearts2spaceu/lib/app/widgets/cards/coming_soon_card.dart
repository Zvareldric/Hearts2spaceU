import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../badges/soon_badge.dart';
import 'app_card.dart';

/// A disabled preview of a capability that doesn't exist yet (e.g. Music,
/// News) — a visual roadmap on Home, not an active feature.
///
/// Non-interactive by design: `onTap` is always null (no ripple), and content
/// is muted + reduced opacity so it reads as clearly disabled. Generic and
/// domain-agnostic — just an icon and a label.
class ComingSoonCard extends StatelessWidget {
  const ComingSoonCard({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.6,
      child: AppCard(
        onTap: null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceTint,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.inkMuted, size: 22),
                ),
                const SoonBadge(),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppColors.inkMuted),
            ),
          ],
        ),
      ),
    );
  }
}
