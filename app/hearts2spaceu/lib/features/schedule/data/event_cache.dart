import 'package:shared_preferences/shared_preferences.dart';

/// What one cached copy of the schedule holds.
typedef CachedSchedule = ({String payload, DateTime fetchedAt});

/// Keeps the last schedule the app managed to fetch.
///
/// The calendar it comes from serves `cache-control: max-age=0`, so nothing
/// between the app and the network will hold on to it — the app has to, or
/// every visit to the Schedule tab waits on a fresh download and an offline
/// phone shows nothing at all.
///
/// Stored in `shared_preferences`, the same place favourites live: the app has
/// one blob to keep, with no queries over it, so a key is enough and a file
/// would mean a new dependency. The blob is a few hundred kilobytes, which
/// prefs handles but is near the top of what it is meant for — if it ever reads
/// slowly, this is the thing to move to a file.
class EventCache {
  const EventCache();

  static const payloadKey = 'schedule.payload';
  static const fetchedAtKey = 'schedule.fetchedAt';

  /// The stored schedule, or null when there is none — or when what is stored
  /// no longer makes sense, which reads as "no cache" rather than as a crash.
  Future<CachedSchedule?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = prefs.getString(payloadKey);
    final stamp = prefs.getString(fetchedAtKey);
    if (payload == null || stamp == null) return null;

    final fetchedAt = DateTime.tryParse(stamp);
    if (fetchedAt == null) return null;

    return (payload: payload, fetchedAt: fetchedAt);
  }

  Future<void> write(String payload, DateTime fetchedAt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(payloadKey, payload);
    await prefs.setString(fetchedAtKey, fetchedAt.toIso8601String());
  }
}
