/// Formats an update's publication date for display, e.g. `05/07/2026`.
///
/// Presentation-only: the domain and data layers keep the raw [DateTime].
/// (Manual for MVP; see the spec's Evolution Notes for the move to `intl`.)
String formatPublishedDate(DateTime dt) {
  final day = dt.day.toString().padLeft(2, '0');
  final month = dt.month.toString().padLeft(2, '0');
  return '$day/$month/${dt.year}';
}
