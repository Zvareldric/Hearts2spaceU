/// Formats an event's start for display, e.g. `15/08/2026 · 19:00`.
///
/// When [allDay] is true the time is left off entirely — the schedule only
/// gave a date, and printing `00:00` would state something the source never
/// said (docs/specs/schedule.md §4).
///
/// Presentation-only: the domain and data layers keep the raw [DateTime].
/// (Manual for MVP; see the spec's Evolution Notes for the move to `intl`.)
String formatEventDateTime(DateTime dt, {bool allDay = false}) {
  final day = dt.day.toString().padLeft(2, '0');
  final month = dt.month.toString().padLeft(2, '0');
  final date = '$day/$month/${dt.year}';

  if (allDay) return date;

  final hour = dt.hour.toString().padLeft(2, '0');
  final minute = dt.minute.toString().padLeft(2, '0');
  return '$date · $hour:$minute';
}
