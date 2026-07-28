import 'event.dart';

/// One calendar month's worth of events, in the order they were given.
class EventMonth {
  const EventMonth({
    required this.year,
    required this.month,
    required this.events,
  });

  final int year;
  final int month;
  final List<Event> events;
}

/// Splits [events] into consecutive calendar months.
///
/// Pure and deterministic; never mutates [events]. It assumes the input is
/// already ordered (as `upcomingSorted` leaves it) and simply starts a new
/// group whenever the month changes — so the months come out in the same
/// order as the events, with no sorting of its own.
List<EventMonth> groupByMonth(List<Event> events) {
  final groups = <EventMonth>[];

  for (final event in events) {
    final year = event.startDateTime.year;
    final month = event.startDateTime.month;
    final current = groups.isEmpty ? null : groups.last;

    if (current != null && current.year == year && current.month == month) {
      current.events.add(event);
    } else {
      groups.add(EventMonth(year: year, month: month, events: [event]));
    }
  }

  return groups;
}
