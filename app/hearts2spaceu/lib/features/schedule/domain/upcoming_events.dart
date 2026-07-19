import 'event.dart';

/// Returns the events at or after [now], sorted by start time ascending.
///
/// Pure and deterministic: it depends only on its arguments (`now` is passed
/// in rather than read from the clock) and never mutates [events] — it builds
/// and returns a new list.
///
/// Ties (equal `startDateTime`) keep their original source order. Because
/// `List.sort` is not guaranteed stable, the original index is used as the
/// tie-breaker to make the ordering stable and predictable.
List<Event> upcomingSorted(List<Event> events, DateTime now) {
  final indexed = <(int, Event)>[];
  for (var i = 0; i < events.length; i++) {
    // "Upcoming" includes events starting exactly at `now` (not yet past).
    if (!events[i].startDateTime.isBefore(now)) {
      indexed.add((i, events[i]));
    }
  }

  indexed.sort((a, b) {
    final byTime = a.$2.startDateTime.compareTo(b.$2.startDateTime);
    return byTime != 0 ? byTime : a.$1.compareTo(b.$1); // stable tie-break
  });

  return [for (final (_, event) in indexed) event];
}
