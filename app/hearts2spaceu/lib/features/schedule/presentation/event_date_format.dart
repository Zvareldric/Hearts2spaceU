/// Formats an event's start time for display, e.g. `15/08/2026 · 19:00`.
///
/// Presentation-only: the domain and data layers keep the raw [DateTime];
/// formatting lives here. (Manual for MVP; see the spec's Evolution Notes for
/// the move to `intl` when localization is needed.)
String formatEventDateTime(DateTime dt) {
  final day = dt.day.toString().padLeft(2, '0');
  final month = dt.month.toString().padLeft(2, '0');
  final hour = dt.hour.toString().padLeft(2, '0');
  final minute = dt.minute.toString().padLeft(2, '0');
  return '$day/$month/${dt.year} · $hour:$minute';
}
