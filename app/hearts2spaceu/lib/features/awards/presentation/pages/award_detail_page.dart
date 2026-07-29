import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/badges/type_badge.dart';
import '../../../../app/widgets/cards/app_card.dart';
import '../../../../app/widgets/layout/meta_row.dart';
import '../../../../app/widgets/states/empty_view.dart';
import '../../../../app/widgets/states/error_view.dart';
import '../../../../app/widgets/states/loading_view.dart';
import '../../../../shared/widgets/external_link_button.dart';
import '../../../collection/domain/favorite.dart';
import '../../../collection/presentation/widgets/favorite_button.dart';
import '../../domain/award.dart';
import '../providers/award_providers.dart';

/// UC-2 — one achievement's details.
class AwardDetailPage extends ConsumerWidget {
  const AwardDetailPage({super.key, required this.awardId});

  final String awardId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final yearsAsync = ref.watch(awardsByYearProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        actions: [FavoriteButton(type: Favorite.typeAward, id: awardId)],
      ),
      body: yearsAsync.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          message: "Couldn't load the award.",
          onRetry: () => ref.invalidate(awardsByYearProvider),
        ),
        data: (years) {
          final matches = years
              .expand((year) => year.awards)
              .where((award) => award.id == awardId);
          if (matches.isEmpty) {
            return const EmptyView(message: 'Award not found.');
          }
          return _AwardDetail(award: matches.first);
        },
      ),
    );
  }
}

/// Renders an award. Only fields that are actually known are shown.
class _AwardDetail extends StatelessWidget {
  const _AwardDetail({required this.award});

  final Award award;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _AwardHero(award: award),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),
              AppCard(
                child: Column(
                  children: [
                    MetaRow(
                      icon: Icons.stadium_rounded,
                      label: 'Awarded by',
                      value: award.ceremony,
                    ),
                    MetaRow(
                      icon: Icons.calendar_today_rounded,
                      label: 'Year',
                      value: '${award.year}',
                    ),
                    if (award.work != null)
                      MetaRow(
                        icon: Icons.album_rounded,
                        label: 'For',
                        value: award.work!,
                      ),
                    if (award.isIndividual)
                      MetaRow(
                        icon: Icons.person_rounded,
                        label: award.members.length > 1 ? 'Members' : 'Member',
                        value: award.members.join(', '),
                      ),
                    if (award.note != null)
                      MetaRow(
                        icon: Icons.notes_rounded,
                        label: 'Note',
                        value: award.note!,
                      ),
                  ],
                ),
              ),
              if (award.sourceUrl != null) ...[
                const SizedBox(height: AppSpacing.xl),
                ExternalLinkButton(
                  url: award.sourceUrl!,
                  label: 'Official source',
                ),
              ],
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ],
    );
  }
}

/// Full-bleed gradient header carrying the award's identity.
class _AwardHero extends StatelessWidget {
  const _AwardHero({required this.award});

  final Award award;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final topInset = MediaQuery.of(context).padding.top;

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
          if (award.type != Award.typeAward) ...[
            TypeBadge(type: award.type),
            const SizedBox(height: AppSpacing.md),
          ],
          Text(award.title, style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${award.ceremony} · ${award.year}',
            style: textTheme.bodyLarge?.copyWith(color: AppColors.inkMuted),
          ),
        ],
      ),
    );
  }
}
