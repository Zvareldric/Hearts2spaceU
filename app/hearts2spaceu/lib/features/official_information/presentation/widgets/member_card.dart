import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/cards/app_card.dart';
import '../../domain/member.dart';
import '../member_palette.dart';

/// Design System V2 member tile — a colored avatar with her initial, the stage
/// name, and her main role, centered in a grid cell.
///
/// Built from generic Design System building blocks ([AppCard]); lives here
/// (not in `app/widgets/`) because it depends on the [Member] domain entity —
/// `app/` must never know about a feature's domain (Checkpoint 2.5).
class MemberCard extends StatelessWidget {
  const MemberCard({
    super.key,
    required this.member,
    required this.color,
    this.onTap,
  });

  final Member member;

  /// Her avatar colour, resolved by the caller via `memberColor` — which needs
  /// the whole member list to hand out distinct colours, and only the page
  /// showing the list has that.
  final Color color;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
        horizontal: AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Flies into the detail page's larger avatar (see MemberDetailPage).
          Hero(
            tag: 'member-avatar-${member.id}',
            child: MemberAvatar(member: member, size: 64, color: color),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            member.stageName,
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (member.positions.isNotEmpty)
            Text(
              member.positions.first,
              textAlign: TextAlign.center,
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
    );
  }
}

/// The circular initial avatar, shared by the member tile and her detail page
/// so the Hero flight has the same thing at both ends.
class MemberAvatar extends StatelessWidget {
  const MemberAvatar({
    super.key,
    required this.member,
    required this.size,
    required this.color,
  });

  final Member member;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Text(
        memberInitial(member.stageName),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.35,
        ),
      ),
    );
  }
}
