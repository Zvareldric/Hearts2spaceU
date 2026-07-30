import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_motion.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/cards/app_card.dart';
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
      appBar: AppBar(title: const Text('Statistics')),
      body: AnimatedSwitcher(
        duration: AppMotion.of(context, AppMotion.base),
        child: statsAsync.when(
          loading: () => const LoadingView(key: ValueKey('loading')),
          error: (error, _) => ErrorView(
            key: const ValueKey('error'),
            message: "Couldn't load the statistics.",
            onRetry: () => ref.invalidate(careerStatsProvider),
          ),
          data: (stats) {
            // A wall of zeros would read as a real result. Say there is nothing
            // to summarise instead.
            if (stats.isEmpty) {
              return const EmptyView(
                key: ValueKey('empty'),
                message: 'No achievements recorded yet.',
                icon: Icons.insights_rounded,
              );
            }
            return _StatsBody(key: const ValueKey('data'), stats: stats);
          },
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
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        StaggeredItem(index: 0, child: _Overview(stats: stats)),
        const SizedBox(height: AppSpacing.xl),
        StaggeredItem(index: 1, child: _ByYear(stats: stats)),
        if (stats.musicShowWinsByWork.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          StaggeredItem(index: 2, child: _MusicShowWins(stats: stats)),
        ],
        const SizedBox(height: AppSpacing.xl),
        const _SourceNote(),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

/// The headline totals — everything readable in about five seconds.
class _Overview extends StatelessWidget {
  const _Overview({required this.stats});

  final CareerStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(label: 'Career so far'),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${stats.total}',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              Text(
                'achievements in total',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.lg),
              // Two rows of two rather than a four-across row: at 360dp a
              // four-across row leaves each label about 70px wide.
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: StatTile(
                      value: stats.ceremonyAwards,
                      label: 'Award wins',
                    ),
                  ),
                  Expanded(
                    child: StatTile(
                      value: stats.musicShowWins,
                      label: 'Music show wins',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: StatTile(
                      value: stats.distinctCeremonies,
                      label: 'Ceremonies & shows',
                    ),
                  ),
                  Expanded(
                    child: StatTile(
                      value: stats.distinctWorks,
                      label: 'Awarded releases',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(label: 'By year'),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Column(
            children: [
              for (final year in stats.byYear)
                CountBar(
                  label: '${year.year}',
                  count: year.count,
                  max: stats.busiestYearCount,
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.awards),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MusicShowWins extends StatelessWidget {
  const _MusicShowWins({required this.stats});

  final CareerStats stats;

  @override
  Widget build(BuildContext context) {
    final top = stats.musicShowWinsByWork.first.count;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(label: 'Music show wins by release'),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Column(
            children: [
              for (final work in stats.musicShowWinsByWork)
                CountBar(label: work.work, count: work.count, max: top),
            ],
          ),
        ),
      ],
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
        Icon(
          Icons.info_outline_rounded,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            'Counted from the achievements recorded in this app. '
            'The list is curated from public sources, so it may not be complete.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
