import '../../awards/domain/award.dart';

/// How many achievements a single year holds.
class YearCount {
  const YearCount({required this.year, required this.count});

  final int year;
  final int count;
}

/// How many music-show wins a single song or album holds.
class WorkCount {
  const WorkCount({required this.work, required this.count});

  final String work;
  final int count;
}

/// A read-only summary of everything Hearts2Hearts has achieved.
///
/// Every number here is *derived* from `awards.json` — the same source the
/// Awards page lists. Nothing is stored separately, so these totals can never
/// disagree with that list (docs/specs/statistics.md §4).
class CareerStats {
  const CareerStats({
    required this.total,
    required this.ceremonyAwards,
    required this.musicShowWins,
    required this.milestones,
    required this.distinctCeremonies,
    required this.distinctWorks,
    required this.byYear,
    required this.musicShowWinsByWork,
  });

  final int total;
  final int ceremonyAwards;
  final int musicShowWins;
  final int milestones;

  /// How many different ceremonies, shows, and platforms have recognised them.
  final int distinctCeremonies;

  /// How many different songs or albums have won something.
  final int distinctWorks;

  /// Most recent year first.
  final List<YearCount> byYear;

  /// Most wins first.
  final List<WorkCount> musicShowWinsByWork;

  bool get isEmpty => total == 0;

  /// The busiest year's count — the scale every year bar is drawn against.
  int get busiestYearCount => byYear.isEmpty
      ? 0
      : byYear.map((y) => y.count).reduce((a, b) => a > b ? a : b);
}

/// Summarises [awards] into the numbers the Statistics page shows.
///
/// Pure and deterministic: no clock, no I/O, never mutates [awards].
CareerStats computeStats(List<Award> awards) {
  final ceremonies = <String>{};
  final works = <String>{};
  final perYear = <int, int>{};
  final winsPerWork = <String, int>{};
  var ceremonyAwards = 0;
  var musicShowWins = 0;
  var milestones = 0;

  for (final award in awards) {
    ceremonies.add(award.ceremony);
    perYear[award.year] = (perYear[award.year] ?? 0) + 1;

    // An achievement with no `work` — a milestone, or an award for the group
    // itself rather than a release — simply isn't counted here.
    final work = award.work;
    if (work != null) works.add(work);

    switch (award.type) {
      case Award.typeMusicShow:
        musicShowWins++;
        if (work != null) {
          winsPerWork[work] = (winsPerWork[work] ?? 0) + 1;
        }
      case Award.typeMilestone:
        milestones++;
      default:
        ceremonyAwards++;
    }
  }

  final years = perYear.keys.toList()..sort((a, b) => b.compareTo(a));

  // Most wins first; ties fall back to the title so the order is stable rather
  // than dependent on map iteration.
  final rankedWorks = winsPerWork.entries.toList()
    ..sort((a, b) {
      final byCount = b.value.compareTo(a.value);
      return byCount != 0 ? byCount : a.key.compareTo(b.key);
    });

  return CareerStats(
    total: awards.length,
    ceremonyAwards: ceremonyAwards,
    musicShowWins: musicShowWins,
    milestones: milestones,
    distinctCeremonies: ceremonies.length,
    distinctWorks: works.length,
    byYear: [
      for (final year in years) YearCount(year: year, count: perYear[year]!),
    ],
    musicShowWinsByWork: [
      for (final entry in rankedWorks)
        WorkCount(work: entry.key, count: entry.value),
    ],
  );
}
