import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/cached_event_repository.dart';
import '../../data/calendar_event_repository.dart';
import '../../data/event_cache.dart';
import '../../domain/event.dart';
import '../../domain/event_repository.dart';
import '../../domain/upcoming_events.dart';

/// Provides the [EventRepository] implementation.
///
/// The feature depends on this provider — not the concrete class — so tests can
/// `override` it with a fake repository without touching the UI.
final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return CachedEventRepository(remote: CalendarEventRepository());
});

/// When the schedule now on screen was fetched.
///
/// Its own provider rather than a field on the events themselves: Home and the
/// Agenda watch the same event list and have no use for the timestamp, and
/// widening their type to carry it would make every one of them handle it.
final scheduleFetchedAtProvider = FutureProvider<DateTime?>((ref) async {
  final cached = await const EventCache().read();
  return cached?.fetchedAt;
}, retry: (_, _) => null);

/// Fetches a new copy of the schedule past the cached one.
///
/// Throws when it cannot. The caller keeps whatever is already on screen and
/// reports the failure — a refresh that fails must not empty the list.
Future<void> refreshSchedule(WidgetRef ref) async {
  await ref.read(eventRepositoryProvider).getEvents(forceRefresh: true);
  ref.invalidate(upcomingEventsProvider);
  ref.invalidate(scheduleFetchedAtProvider);
}

/// Loads events and exposes the upcoming ones (sorted) as an [AsyncValue].
///
/// The provider stays thin: it fetches all events, then delegates the time
/// logic to the pure `upcomingSorted`, passing `DateTime.now()`.
final upcomingEventsProvider = FutureProvider<List<Event>>(
  (ref) async {
    final repository = ref.watch(eventRepositoryProvider);
    final all = await repository.getEvents();
    return upcomingSorted(all, DateTime.now());
  },
  // No automatic retry (a Riverpod 3.x default): a silent retry would hide a
  // dead network behind a longer spinner, and the UI offers an explicit Retry.
  retry: (_, _) => null,
);
