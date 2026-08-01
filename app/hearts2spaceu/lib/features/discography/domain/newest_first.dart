import 'release.dart';

/// Orders [releases] newest first.
///
/// Pure and deterministic: no clock, no I/O, never mutates [releases].
///
/// Sorts on [Release.releaseDate] when both entries have one and falls back to
/// [Release.year] otherwise, so a curated exact date always outranks the year it
/// sits in. Ties fall back to the title, so the order is stable rather than
/// dependent on the order the source file happened to list them in.
List<Release> newestFirst(List<Release> releases) {
  final sorted = [...releases]
    ..sort((a, b) {
      final aDate = a.releaseDate;
      final bDate = b.releaseDate;
      if (aDate != null && bDate != null) {
        final byDate = bDate.compareTo(aDate);
        if (byDate != 0) return byDate;
      }
      final byYear = b.year.compareTo(a.year);
      return byYear != 0 ? byYear : a.title.compareTo(b.title);
    });
  return List.unmodifiable(sorted);
}
