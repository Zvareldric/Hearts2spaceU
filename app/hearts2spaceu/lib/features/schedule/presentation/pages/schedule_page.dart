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
import '../../domain/month_groups.dart';
import '../event_date_format.dart';
import '../providers/event_providers.dart';
import '../widgets/event_card.dart';

/// UC-1 — the list of upcoming events. Design System V1 (Checkpoint 4).
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
      appBar: AppBar(title: const Text('Schedule')),
      // Cross-fades between loading/empty/error/data instead of snapping.
      body: AnimatedSwitcher(
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
            return _MonthlySchedule(
              key: const ValueKey('data'),
              months: groupByMonth(events),
            );
          },
        ),
      ),
    );
  }
}

/// The schedule as month sections whose headers stay pinned while that month
/// scrolls past, so it stays clear where you are in a long list.
class _MonthlySchedule extends StatelessWidget {
  const _MonthlySchedule({super.key, required this.months});

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
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
      ],
    );
  }
}

/// A pinned month heading.
///
/// Its background is opaque on purpose: a pinned header floats above the list,
/// so cards would otherwise show through as they slide underneath.
class _MonthHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _MonthHeaderDelegate({required this.label});

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
  bool shouldRebuild(_MonthHeaderDelegate oldDelegate) =>
      oldDelegate.label != label;
}
