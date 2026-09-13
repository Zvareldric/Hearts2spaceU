import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_motion.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/glass/glass_nav_bar.dart';
import '../../../../app/widgets/glass/glass_surface.dart';
import '../../../../app/widgets/layout/page_heading.dart';
import '../../../../app/widgets/layout/section_header.dart';
import '../../../../app/widgets/layout/staggered_item.dart';
import '../../../../app/widgets/states/empty_view.dart';
import '../../../../app/widgets/states/error_view.dart';
import '../../../../app/widgets/states/loading_view.dart';
import '../../../../routes/app_routes.dart';
import '../../domain/month_groups.dart';
import '../event_date_format.dart';
import '../providers/event_providers.dart';
import '../widgets/event_card.dart';

/// UC-1 — the list of upcoming events. A tab root, so it carries a large inline
/// title instead of an AppBar (Design System V2).
///
/// Presentation only: it watches [upcomingEventsProvider] and renders the
/// matching state. Loading, filtering, and sorting live in the provider and the
/// pure `upcomingSorted` function.
class SchedulePage extends ConsumerWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(upcomingEventsProvider);

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
              child: PageHeading(title: 'Schedule'),
            ),
            const _ScheduleSource(),
            Expanded(
              // Cross-fades between loading/empty/error/data instead of
              // snapping.
              child: AnimatedSwitcher(
                duration: AppMotion.of(context, AppMotion.base),
                child: eventsAsync.when(
                  loading: () => const LoadingView(key: ValueKey('loading')),
                  error: (error, _) => ErrorView(
                    key: const ValueKey('error'),
                    message: 'Failed to load the schedule.',
                    onRetry: () => ref.invalidate(upcomingEventsProvider),
                  ),
                  data: (events) {
                    if (events.isEmpty) {
                      return const EmptyView(
                        key: ValueKey('empty'),
                        message: 'No upcoming events.',
                      );
                    }
                    return RefreshIndicator(
                      key: const ValueKey('data'),
                      onRefresh: () => _refresh(context, ref),
                      child: _MonthlySchedule(months: groupByMonth(events)),
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

/// Pulls a newer schedule down, keeping the list on screen if it cannot.
///
/// A refresh that fails leaves the reader with the copy they already had and a
/// line saying so — emptying the schedule because the network blinked would be
/// a worse answer than showing yesterday's.
Future<void> _refresh(BuildContext context, WidgetRef ref) async {
  try {
    await refreshSchedule(ref);
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Could not reach the calendar. Showing the saved copy.'),
      ),
    );
  }
}

/// Where the schedule came from, and how old it is.
///
/// Both belong on screen: the events are fetched from a calendar other fans
/// maintain, which deserves the credit, and a cached list has to say how stale
/// it is rather than pass itself off as live.
class _ScheduleSource extends ConsumerWidget {
  const _ScheduleSource();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fetchedAt = ref.watch(scheduleFetchedAtProvider).asData?.value;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.xs,
        AppSpacing.screenPadding,
        AppSpacing.sm,
      ),
      child: Text(
        [
          if (fetchedAt != null) formatFetchedAt(fetchedAt, DateTime.now()),
          'Schedule by h2hcalendar.com',
        ].join(' · '),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.inkMuted,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// The schedule as month sections whose headers stay pinned while that month
/// scrolls past, so it stays clear where you are in a long list.
class _MonthlySchedule extends StatelessWidget {
  const _MonthlySchedule({required this.months});

  final List<EventMonth> months;

  @override
  Widget build(BuildContext context) {
    // One running index so the entry animation cascades down the page rather
    // than restarting inside every month.
    var animationIndex = 0;

    return CustomScrollView(
      slivers: [
        for (final month in months) ...[
          SliverPersistentHeader(
            pinned: true,
            delegate: _MonthHeaderDelegate(
              label: formatMonthLabel(month.year, month.month),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
            ),
            sliver: SliverList.builder(
              itemCount: month.events.length,
              itemBuilder: (context, index) {
                final event = month.events[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: StaggeredItem(
                    index: animationIndex++,
                    child: EventCard(
                      event: event,
                      onTap: () => Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.eventDetail, arguments: event.id),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        // Clear the floating nav bar this list scrolls underneath.
        const SliverToBoxAdapter(
          child: SizedBox(height: GlassNavBar.reservedSpace),
        ),
      ],
    );
  }
}

/// A pinned month heading.
///
/// It blurs rather than covers: a pinned header floats above the list, and the
/// ambient wash means there is no opaque color left to fill it with. The blur is
/// what keeps cards from reading through legibly as they slide underneath.
class _MonthHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _MonthHeaderDelegate({required this.label});

  final String label;

  static const _height = 40.0;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    return GlassSurface(
      borderRadius: BorderRadius.zero,
      border: false,
      blur: 18,
      child: Container(
        height: _height,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
        ),
        child: SectionHeader(label: label),
      ),
    );
  }

  @override
  bool shouldRebuild(_MonthHeaderDelegate oldDelegate) =>
      oldDelegate.label != label;
}
