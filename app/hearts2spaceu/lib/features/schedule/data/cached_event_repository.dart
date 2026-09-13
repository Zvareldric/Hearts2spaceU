import '../domain/event.dart';
import '../domain/event_repository.dart';
import 'calendar_event_repository.dart';
import 'event_cache.dart';

/// Serves the schedule from the last copy the app fetched, and goes to the
/// network only when asked.
///
/// The Schedule tab opens on what is already stored, so it is instant and it
/// works on a plane. The reader decides when to go and get a newer one by
/// pulling the list down — nothing refetches behind their back, and the page
/// says out loud how old what they are looking at is.
class CachedEventRepository implements EventRepository {
  CachedEventRepository({
    required this.remote,
    this.cache = const EventCache(),
  });

  final CalendarEventRepository remote;
  final EventCache cache;

  /// When the copy now in hand was fetched. Null before anything is loaded.
  DateTime? get fetchedAt => _fetchedAt;
  DateTime? _fetchedAt;

  @override
  Future<List<Event>> getEvents({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await cache.read();
      if (cached != null) {
        _fetchedAt = cached.fetchedAt;
        return CalendarEventRepository.parseEvents(cached.payload);
      }
    }

    // Either nothing is stored yet, or the reader asked for a newer copy. A
    // failure here is thrown rather than swallowed: with no cache there is
    // nothing to show, and on a pull-to-refresh the caller keeps the list on
    // screen and reports the failure without discarding what is already there.
    final raw = await remote.fetchRaw();
    final now = DateTime.now();
    await cache.write(raw, now);
    _fetchedAt = now;
    return CalendarEventRepository.parseEvents(raw);
  }
}
