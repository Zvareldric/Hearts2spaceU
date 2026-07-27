import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/cards/app_card.dart';
import '../../domain/member.dart';

/// Design System V1 member card — large avatar, gradient ring, modern layout.
///
/// Built from generic Design System building blocks ([AppCard]); lives here
/// (not in `app/widgets/`) because it depends on the [Member] domain entity —
/// `app/` must never know about a feature's domain (Checkpoint 2.5).
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
            child: const CircleAvatar(
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
              // min: without it the Column fills any bounded height it is
              // given, making the card's height depend on its context.
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  member.stageName,
                  style: textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (positions.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    positions,
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
          const Icon(Icons.chevron_right_rounded, color: AppColors.inkMuted),
        ],
      ),
    );
  }
}
