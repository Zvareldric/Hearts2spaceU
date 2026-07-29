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
  // Compare against the start of today, not the current instant: an event is
  // still "upcoming" for the whole day it happens on. Comparing to `now` made
  // an all-day event (stored at midnight) vanish at 00:01, and a 19:00 concert
  // vanish at 19:01 while it was still going on.
  final today = DateTime(now.year, now.month, now.day);

  final indexed = <(int, Event)>[];
  for (var i = 0; i < events.length; i++) {
    if (!events[i].startDateTime.isBefore(today)) {
      indexed.add((i, events[i]));
    }
  }

  indexed.sort((a, b) {
    final byTime = a.$2.startDateTime.compareTo(b.$2.startDateTime);
    return byTime != 0 ? byTime : a.$1.compareTo(b.$1); // stable tie-break
  });

  return [for (final (_, event) in indexed) event];
}
