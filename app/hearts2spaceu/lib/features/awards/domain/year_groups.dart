import 'award.dart';

/// One year's worth of awards, in the order they were given.
class AwardYear {
  const AwardYear({required this.year, required this.awards});

  final int year;
  final List<Award> awards;
}

/// Groups [awards] by year, most recent year first.
///
/// Pure and deterministic; never mutates [awards].
///
/// Only the *years* are sorted. Within a year the source order is kept, because
/// `awards.json` is curated and its ordering is an editorial choice — and most
/// entries have no date precise enough to sort by anyway.
List<AwardYear> groupByYear(List<Award> awards) {
  final byYear = <int, List<Award>>{};

  for (final award in awards) {
    byYear.putIfAbsent(award.year, () => []).add(award);
  }

  final years = byYear.keys.toList()..sort((a, b) => b.compareTo(a));

  return [
    for (final year in years) AwardYear(year: year, awards: byYear[year]!),
  ];
}
