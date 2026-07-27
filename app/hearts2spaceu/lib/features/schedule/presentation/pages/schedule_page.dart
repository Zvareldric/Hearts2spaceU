import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_motion.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/layout/staggered_item.dart';
import '../../../../app/widgets/states/empty_view.dart';
import '../../../../app/widgets/states/error_view.dart';
import '../../../../app/widgets/states/loading_view.dart';
import '../../../../routes/app_routes.dart';
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
            return ListView.separated(
              key: const ValueKey('data'),
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              itemCount: events.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final event = events[index];
                return StaggeredItem(
                  index: index,
                  child: EventCard(
                    event: event,
                    onTap: () => Navigator.of(
                      context,
                    ).pushNamed(AppRoutes.eventDetail, arguments: event.id),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
