import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/buttons/secondary_button.dart';
import '../../../../app/widgets/cards/app_card.dart';
import '../../../../app/widgets/layout/meta_row.dart';
import '../../../../app/widgets/states/empty_view.dart';
import '../../../../app/widgets/states/error_view.dart';
import '../../../../app/widgets/states/loading_view.dart';
import '../../domain/member.dart';
import '../providers/member_providers.dart';

/// UC-2 — one member's details. Design System V1 (Checkpoint 6).
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
      // The hero runs behind the (transparent) app bar, which is reduced to a
      // back button — the hero itself carries the page's identity.
      extendBodyBehindAppBar: true,
      appBar: AppBar(),
      body: membersAsync.when(
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
          return _MemberDetail(member: matches.first);
        },
      ),
    );
  }
}

/// Renders a member. Only non-null optional fields are shown, and the date is
/// formatted here (presentation) — the domain keeps the raw [DateTime].
class _MemberDetail extends StatelessWidget {
  const _MemberDetail({required this.member});

  final Member member;

  @override
  Widget build(BuildContext context) {
    final hasMeta = member.fullName != null || member.birthDate != null;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _MemberHero(member: member),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),
              if (hasMeta)
                AppCard(
                  child: Column(
                    children: [
                      if (member.fullName != null)
                        MetaRow(
                          icon: Icons.badge_rounded,
                          label: 'Full name',
                          value: member.fullName!,
                        ),
                      if (member.birthDate != null)
                        MetaRow(
                          icon: Icons.cake_rounded,
                          label: 'Born',
                          value: _formatDate(member.birthDate!),
                        ),
                    ],
                  ),
                ),
              if (member.officialProfileUrl != null) ...[
                const SizedBox(height: AppSpacing.xl),
                // Disabled for now: opening links needs url_launcher, which is
                // still out of scope (docs/specs/official-information.md).
                const SecondaryButton(
                  label: 'Official profile (soon)',
                  icon: Icons.open_in_new_rounded,
                ),
              ],
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ],
    );
  }

  static String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }
}

/// Full-bleed gradient header with a large avatar carrying the member's
/// identity.
class _MemberHero extends StatelessWidget {
  const _MemberHero({required this.member});

  final Member member;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final topInset = MediaQuery.of(context).padding.top;
    final positions = member.positions.join(' · ');

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        topInset + kToolbarHeight + AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.xxl,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.heroGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.xl),
          bottomRight: Radius.circular(AppRadius.xl),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Receives the avatar flying in from the list's MemberCard.
          Hero(
            tag: 'member-avatar-${member.id}',
            child: Container(
              width: 96,
              height: 96,
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
              ),
              child: const CircleAvatar(
                backgroundColor: AppColors.surfaceTint,
                child: Icon(
                  Icons.person_rounded,
                  color: AppColors.primaryStrong,
                  size: 44,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(member.stageName, style: textTheme.headlineSmall),
          if (positions.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              positions,
              style: textTheme.bodyLarge?.copyWith(color: AppColors.inkMuted),
            ),
          ],
        ],
      ),
    );
  }
}
