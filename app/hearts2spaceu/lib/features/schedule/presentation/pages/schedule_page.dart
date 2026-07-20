import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../routes/app_routes.dart';
import '../providers/event_providers.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/event_card.dart';
import '../widgets/loading_view.dart';

/// UC-1 — the list of upcoming events.
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
      body: eventsAsync.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          message: 'Failed to load the schedule.',
          onRetry: () => ref.invalidate(upcomingEventsProvider),
        ),
        data: (events) {
          if (events.isEmpty) {
            return const EmptyView(message: 'No upcoming events.');
          }
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return EventCard(
                event: event,
                onTap: () => Navigator.of(
                  context,
                ).pushNamed(AppRoutes.eventDetail, arguments: event.id),
              );
            },
          );
        },
      ),
    );
  }
}
