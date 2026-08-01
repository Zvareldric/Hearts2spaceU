import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/cards/app_card.dart';
import '../../../../app/widgets/layout/page_heading.dart';
import '../../../../app/widgets/states/empty_view.dart';
import '../../../../app/widgets/states/error_view.dart';
import '../../../../app/widgets/states/loading_view.dart';
import '../../../../shared/widgets/external_link_button.dart';
import '../../../collection/domain/favorite.dart';
import '../../../collection/presentation/widgets/favorite_button.dart';
import '../../domain/member.dart';
import '../member_palette.dart';
import '../providers/member_providers.dart';
import '../widgets/member_card.dart';

/// UC-2 — one member's details, as a single centered profile card
/// (Design System V2).
///
/// Reuses the cached [membersProvider] (no refetch) and selects by id, which
/// also exercises the same Loading/Empty/Error views as the list.
class MemberDetailPage extends ConsumerWidget {
  const MemberDetailPage({super.key, required this.memberId});

  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(membersProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.lg,
                AppSpacing.sm,
                0,
              ),
              child: PageHeading.sub(
                title: '',
                trailing: FavoriteButton(
                  type: Favorite.typeMember,
                  id: memberId,
                ),
              ),
            ),
            Expanded(
              child: membersAsync.when(
                loading: () => const LoadingView(),
                error: (error, _) => ErrorView(
                  message: "Couldn't load the member.",
                  onRetry: () => ref.invalidate(membersProvider),
                ),
                data: (members) {
                  final matches = members.where((m) => m.id == memberId);
                  if (matches.isEmpty) {
                    return const EmptyView(message: 'Member not found.');
                  }
                  // Same roster the list ranks against, so the avatar keeps its
                  // colour through the Hero flight.
                  return _MemberDetail(
                    member: matches.first,
                    color: memberColor(
                      memberId,
                      members.map((m) => m.id).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Renders a member. Only non-null optional fields are shown, and the date is
/// formatted here (presentation) — the domain keeps the raw [DateTime].
class _MemberDetail extends StatelessWidget {
  const _MemberDetail({required this.member, required this.color});

  final Member member;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        0,
        AppSpacing.screenPadding,
        AppSpacing.xl,
      ),
      children: [
        AppCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Receives the avatar flying in from the list's MemberCard.
              Center(
                child: Hero(
                  tag: 'member-avatar-${member.id}',
                  child: MemberAvatar(member: member, size: 96, color: color),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                member.stageName,
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall,
              ),
              if (member.fullName case final fullName?) ...[
                const SizedBox(height: 2),
                Text(
                  fullName,
                  textAlign: TextAlign.center,
                  style: textTheme.labelMedium?.copyWith(
                    color: AppColors.inkMuted,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
              if (member.positions.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final position in member.positions)
                      _PositionPill(label: position),
                  ],
                ),
              ],
              if (member.birthDate case final birthDate?) ...[
                const SizedBox(height: AppSpacing.xl),
                Divider(
                  height: 1,
                  color: AppColors.primaryStrong.withValues(alpha: 0.22),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Birthday',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ),
                    Text(
                      _formatDate(birthDate),
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        if (member.officialProfileUrl case final url?) ...[
          const SizedBox(height: AppSpacing.lg),
          ExternalLinkButton(url: url, label: 'Official profile'),
        ],
      ],
    );
  }

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String _formatDate(DateTime date) =>
      '${_months[date.month - 1]} ${date.day}, ${date.year}';
}

/// One role, as a lavender pill.
class _PositionPill extends StatelessWidget {
  const _PositionPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs + 1,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.5),
        borderRadius: AppRadius.pillRadius,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppColors.primaryStrong,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
