import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/cards/app_card.dart';
import '../../domain/member.dart';

/// Design System V1 member card — large avatar, gradient ring, modern layout.
///
/// Built from generic Design System building blocks ([AppCard]); lives here
/// (not in `app/widgets/`) because it depends on the [Member] domain entity —
/// `app/` must never know about a feature's domain (Checkpoint 2.5 cleanup).
///
/// Staged, not yet wired: `member_list_page.dart` still renders the older
/// `MemberCard` (`ListTile`-based) below. This becomes the real `MemberCard`
/// — replacing that file — at the **Members Refresh** checkpoint.
class MemberCardRefresh extends StatelessWidget {
  const MemberCardRefresh({super.key, required this.member, this.onTap});

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
