import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_motion.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/cards/app_card.dart';
import '../../../../app/widgets/layout/page_heading.dart';
import '../../../../app/widgets/layout/section_header.dart';
import '../../../../app/widgets/layout/staggered_item.dart';
import '../../../../app/widgets/states/empty_view.dart';
import '../../../../app/widgets/states/error_view.dart';
import '../../../../app/widgets/states/loading_view.dart';
import '../../../../routes/app_routes.dart';
import '../../domain/career_stats.dart';
import '../providers/statistics_providers.dart';
import '../widgets/count_bar.dart';
import '../widgets/stat_tile.dart';

/// UC-1 — how far Hearts2Hearts has come, in numbers.
///
/// The Awards page answers "which ones"; this one answers "how many".
class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(careerStatsProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.lg,
                AppSpacing.screenPadding,
                0,
              ),
              child: PageHeading.sub(title: 'Fan Statistics'),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: AppMotion.of(context, AppMotion.base),
                child: statsAsync.when(
                  loading: () => const LoadingView(key: ValueKey('loading')),
                  error: (error, _) => ErrorView(
                    key: const ValueKey('error'),
                    message: "Couldn't load the statistics.",
                    onRetry: () => ref.invalidate(careerStatsProvider),
                  ),
                  data: (stats) {
                    // A wall of zeros would read as a real result. Say there is
                    // nothing to summarise instead.
                    if (stats.isEmpty) {
                      return const EmptyView(
                        key: ValueKey('empty'),
                        message: 'No achievements recorded yet.',
                        icon: Icons.insights_rounded,
                      );
                    }
                    return _StatsBody(
                      key: const ValueKey('data'),
                      stats: stats,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsBody extends StatelessWidget {
  const _StatsBody({super.key, required this.stats});

  final CareerStats stats;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        0,
        AppSpacing.screenPadding,
        AppSpacing.xl,
      ),
      children: [
        StaggeredItem(index: 0, child: _Overview(stats: stats)),
        const SizedBox(height: AppSpacing.lg),
        StaggeredItem(index: 1, child: _ByYear(stats: stats)),
        if (stats.musicShowWinsByWork.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          StaggeredItem(index: 2, child: _MusicShowWins(stats: stats)),
        ],
        const SizedBox(height: AppSpacing.lg),
        const _SourceNote(),
      ],
    );
  }
}

/// The headline totals as a 2×2 grid of tiles — everything readable in about
/// five seconds.
class _Overview extends StatelessWidget {
  const _Overview({required this.stats});

  final CareerStats stats;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      (value: stats.total, label: 'Total achievements'),
      (value: stats.musicShowWins, label: 'Music show wins'),
      (value: stats.ceremonyAwards, label: 'Ceremony awards'),
      (value: stats.milestones, label: 'Milestones'),
    ];

    return GridView.count(
      // Inside a ListView: let the grid size to its content instead of taking a
      // viewport of its own.
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      crossAxisCount: 2,
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.9,
      children: [
        for (final tile in tiles)
          StatTile(value: tile.value, label: tile.label),
      ],
    );
  }
}

/// UC-2/UC-3 — the shape of their progress, and a way into the full list.
class _ByYear extends StatelessWidget {
  const _ByYear({required this.stats});

  final CareerStats stats;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(label: 'Achievements by year'),
          for (final year in stats.byYear)
            CountBar(
              label: '${year.year}',
              count: year.count,
              max: stats.busiestYearCount,
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.awards),
            ),
        ],
      ),
    );
  }
}

/// Wins per release as a plain ranked list: with five entries the ranking is the
/// point, and five more bars would just repeat the card above.
class _MusicShowWins extends StatelessWidget {
  const _MusicShowWins({required this.stats});

  final CareerStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final works = stats.musicShowWinsByWork;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(label: 'Music show wins by release'),
          const SizedBox(height: AppSpacing.xs),
          for (final (index, work) in works.indexed)
            Container(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                border: index == works.length - 1
                    ? null
                    : Border(
                        bottom: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.35),
                        ),
                      ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      work.work,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${work.count}×',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.primaryStrong,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Honesty line: these totals count what the app has on file, which is curated
/// from public sources and may be incomplete (docs/specs/statistics.md §4).
class _SourceNote extends StatelessWidget {
  const _SourceNote();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.info_outline_rounded,
          size: 15,
          color: AppColors.inkMuted,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            'Counted from the achievements recorded in this app. '
            'The list is curated from public sources, so it may not be complete.',
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.inkMuted,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
