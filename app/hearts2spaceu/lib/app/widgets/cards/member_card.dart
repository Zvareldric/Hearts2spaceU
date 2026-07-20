import 'package:flutter/material.dart';

import '../../../features/official_information/domain/member.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import 'app_card.dart';

/// Design System V1 member card — large avatar, gradient ring, modern layout.
///
/// Lives in `app/widgets/cards/` (not the feature folder) because the design
/// proposal calls it a shared design-system component; it depends on the
/// [Member] domain entity since that's the whole point of the component. Not
/// yet wired into any page — `official_information` still renders its own
/// local `MemberCard` (`ListTile`-based) until the Members Refresh checkpoint
/// swaps it in.
class MemberCard extends StatelessWidget {
  const MemberCard({super.key, required this.member, this.onTap});

  final Member member;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final positions = member.positions.join(' · ');

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: AppColors.heroGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: CircleAvatar(
              backgroundColor: AppColors.surface,
              child: Icon(
                Icons.person_rounded,
                color: AppColors.primaryStrong,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.stageName, style: textTheme.titleMedium),
                if (positions.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    positions,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.inkMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.inkMuted),
        ],
      ),
    );
  }
}
