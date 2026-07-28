import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_motion.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/layout/section_header.dart';
import '../../../../app/widgets/layout/staggered_item.dart';
import '../../../../app/widgets/states/empty_view.dart';
import '../../../../app/widgets/states/error_view.dart';
import '../../../../app/widgets/states/loading_view.dart';
import '../../../../routes/app_routes.dart';
import '../../domain/year_groups.dart';
import '../providers/award_providers.dart';
import '../widgets/award_card.dart';

/// UC-1 — every achievement, grouped by year.
class AwardsPage extends ConsumerWidget {
  const AwardsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final yearsAsync = ref.watch(awardsByYearProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Awards')),
      body: AnimatedSwitcher(
        duration: AppMotion.of(context, AppMotion.base),
        child: yearsAsync.when(
          loading: () => const LoadingView(key: ValueKey('loading')),
          error: (error, _) => ErrorView(
            key: const ValueKey('error'),
            message: "Couldn't load the awards.",
            onRetry: () => ref.invalidate(awardsByYearProvider),
          ),
          data: (years) {
            if (years.isEmpty) {
              return const EmptyView(
                key: ValueKey('empty'),
                message: 'No awards yet.',
                icon: Icons.emoji_events_rounded,
              );
            }
            return _AwardsByYear(key: const ValueKey('data'), years: years);
          },
        ),
      ),
    );
  }
}

/// Awards as year sections whose headings stay pinned while that year scrolls
/// past, so it stays clear which year you are looking at.
class _AwardsByYear extends StatelessWidget {
  const _AwardsByYear({super.key, required this.years});

  final List<AwardYear> years;

  @override
  Widget build(BuildContext context) {
    // One running index so the entry animation cascades down the page rather
    // than restarting inside every year.
    var animationIndex = 0;

    return CustomScrollView(
      slivers: [
        for (final year in years) ...[
          SliverPersistentHeader(
            pinned: true,
            delegate: _YearHeaderDelegate(label: '${year.year}'),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
            ),
            sliver: SliverList.builder(
              itemCount: year.awards.length,
              itemBuilder: (context, index) {
                final award = year.awards[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: StaggeredItem(
                    index: animationIndex++,
                    child: AwardCard(
                      award: award,
                      onTap: () => Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.awardDetail, arguments: award.id),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
      ],
    );
  }
}

/// A pinned year heading.
///
/// Deliberately duplicated from `schedule_page.dart` rather than shared: this
/// is only the second list that needs it, and the project's Rule of Three says
/// to extract on the third. See docs/specs/awards.md §6.
class _YearHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _YearHeaderDelegate({required this.label});

  final String label;

  static const _height = 44.0;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    return Container(
      height: _height,
      alignment: Alignment.centerLeft,
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: SectionHeader(label: label),
    );
  }

  @override
  bool shouldRebuild(_YearHeaderDelegate oldDelegate) =>
      oldDelegate.label != label;
}
