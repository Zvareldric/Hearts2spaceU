import '../domain/event.dart';
import '../domain/zoned_time.dart';

/// Formats an event's start for display, e.g. `15/08/2026 · 19:00`.
///
/// When [allDay] is true the time is left off entirely — the schedule only
/// gave a date, and printing `00:00` would state something the source never
/// said (docs/specs/schedule.md §4).
///
/// Presentation-only: the domain and data layers keep the raw [DateTime].
/// (Manual for MVP; see the spec's Evolution Notes for the move to `intl`.)
const _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// Labels a month section, e.g. `August 2026`.
String formatMonthLabel(int year, int month) =>
    '${_monthNames[month - 1]} $year';

String formatEventDateTime(DateTime dt, {bool allDay = false}) {
  final day = dt.day.toString().padLeft(2, '0');
  final month = dt.month.toString().padLeft(2, '0');
  final date = '$day/$month/${dt.year}';

  if (allDay) return date;

  final hour = dt.hour.toString().padLeft(2, '0');
  final minute = dt.minute.toString().padLeft(2, '0');
  return '$date · $hour:$minute';
}

/// Just the clock part of a [DateTime], e.g. `19:00`.
String formatTimeOfDay(DateTime dt) =>
    '${dt.hour.toString().padLeft(2, '0')}'
    ':${dt.minute.toString().padLeft(2, '0')}';

/// A start time on the reader's clock, with the published one beside it:
/// `16:00 WIB (18:00 KST)`.
///
/// Fans memorise schedules in the times the source published — KST and JST —
/// and check the app against posters and calendars written that way, so the
/// published time is never dropped. But the reader still needs to know when to
/// actually be there, so their own clock leads.
///
/// Collapses to a single time whenever the second one would say nothing new: a
/// time with no recorded zone, a zone whose offset could not be pinned down,
/// and a reader already on the event's clock. Returns an empty string for an
/// all-day event, which has no time at all.
///
/// Takes plain values rather than an entity so the Agenda, which flattens
/// events into its own row type, prints exactly the same string as the
/// Schedule does — one event must never show two different times.
String formatClock({
  required DateTime published,
  required bool allDay,
  String? zoneLabel,
  Duration? zoneOffset,
}) {
  if (allDay) return '';

  final time = formatTimeOfDay(published);
  if (zoneLabel == null) return time;

  final local = toReaderClock(published, zoneOffset);
  if (zoneOffset == null || zoneOffset == local.timeZoneOffset) {
    return '$time $zoneLabel';
  }
  return '${formatTimeOfDay(local)} ${local.timeZoneName} ($time $zoneLabel)';
}

/// [formatClock] for an [Event].
String formatEventClock(Event event) => formatClock(
  published: event.startDateTime,
  allDay: event.allDay,
  zoneLabel: event.zoneLabel,
  zoneOffset: event.zoneOffset,
);

/// An event's full start — date, then [formatEventClock].
String formatEventWhen(Event event) {
  final date = formatEventDateTime(event.startDateTime, allDay: true);
  final clock = formatEventClock(event);
  return clock.isEmpty ? date : '$date · $clock';
}

/// How long ago the schedule on screen was fetched, e.g. `Updated 3 hours ago`.
///
/// The schedule is served from the last copy the app managed to download, so
/// the reader is owed a plain statement of how old it is. Rounded down and kept
/// coarse on purpose: the point is "is this current?", not the exact minute.
String formatFetchedAt(DateTime fetchedAt, DateTime now) {
  final elapsed = now.difference(fetchedAt);

  return switch (elapsed) {
    // A clock that has gone backwards reads as fresh rather than as nonsense.
    _ when elapsed.isNegative || elapsed.inMinutes < 1 => 'Updated just now',
    _ when elapsed.inHours < 1 =>
      'Updated ${_ago(elapsed.inMinutes, 'minute')}',
    _ when elapsed.inDays < 1 => 'Updated ${_ago(elapsed.inHours, 'hour')}',
    _ => 'Updated ${_ago(elapsed.inDays, 'day')}',
  };
}

String _ago(int count, String unit) =>
    '$count $unit${count == 1 ? '' : 's'} ago';
