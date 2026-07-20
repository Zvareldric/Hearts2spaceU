import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/event.dart';
import '../event_date_format.dart';
import '../providers/event_providers.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';

/// UC-2 — one event's details. Reuses the cached [upcomingEventsProvider] and
/// selects by id (same Loading/Empty/Error views as the list).
class EventDetailPage extends ConsumerWidget {
  const EventDetailPage({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(upcomingEventsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Event')),
      body: eventsAsync.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          message: 'Failed to load the event.',
          onRetry: () => ref.invalidate(upcomingEventsProvider),
        ),
        data: (events) {
          final matches = events.where((e) => e.id == eventId);
          if (matches.isEmpty) {
            return const EmptyView(message: 'Event not found.');
          }
          return _EventDetail(event: matches.first);
        },
      ),
    );
  }
}

/// Renders an event's fields. Only non-null optional fields are shown, and the
/// date/time is formatted here (presentation) — never in domain/data.
class _EventDetail extends StatelessWidget {
  const _EventDetail({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(event.title, style: textTheme.headlineSmall),
        const SizedBox(height: 16),
        _DetailRow('When', formatEventDateTime(event.startDateTime)),
        if (event.type != null) _DetailRow('Type', event.type!),
        if (event.location != null) _DetailRow('Location', event.location!),
        if (event.description != null)
          _DetailRow('Description', event.description!),
        if (event.officialUrl != null)
          _DetailRow('Official link', event.officialUrl!),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          Text(value),
        ],
      ),
    );
  }
}
