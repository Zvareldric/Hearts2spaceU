import 'update.dart';

/// Returns [updates] sorted newest first.
///
/// Pure and deterministic: it depends only on its argument and never mutates
/// [updates] — it builds and returns a new list.
///
/// Ties (equal `publishedAt`) keep their original source order. Because
/// `List.sort` is not guaranteed stable, the original index is used as the
/// tie-breaker to make the ordering predictable.
///
/// Unlike the schedule's `upcomingSorted`, nothing is filtered out: an update
/// stays relevant after publication, so there is no "now" to compare against.
List<Update> latestFirst(List<Update> updates) {
  final indexed = <(int, Update)>[
    for (var i = 0; i < updates.length; i++) (i, updates[i]),
  ];

  indexed.sort((a, b) {
    // Descending: b compared to a.
    final byTime = b.$2.publishedAt.compareTo(a.$2.publishedAt);
    return byTime != 0 ? byTime : a.$1.compareTo(b.$1); // stable tie-break
  });

  return [for (final (_, update) in indexed) update];
}
