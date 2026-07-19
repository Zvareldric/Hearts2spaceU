import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/asset_event_repository.dart';
import '../../domain/event.dart';
import '../../domain/event_repository.dart';
import '../../domain/upcoming_events.dart';

/// Provides the [EventRepository] implementation.
///
/// The feature depends on this provider — not the concrete class — so tests can
/// `override` it with a fake repository without touching the UI.
final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return const AssetEventRepository();
});

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
  // No automatic retry (a Riverpod 3.x default): the source is a local asset,
  // so failures are not transient, and the UI offers an explicit Retry.
  retry: (_, _) => null,
);
