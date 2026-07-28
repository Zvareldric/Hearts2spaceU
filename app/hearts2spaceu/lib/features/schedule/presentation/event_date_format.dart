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
