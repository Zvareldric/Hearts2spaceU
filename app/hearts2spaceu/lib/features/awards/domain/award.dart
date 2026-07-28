/// Something Hearts2Hearts has won or reached.
///
/// Pure, immutable domain entity. Covers three kinds of achievement, told
/// apart by [type]: ceremony awards, music-show wins, and platform milestones.
class Award {
  const Award({
    required this.id,
    required this.title,
    required this.ceremony,
    required this.year,
    this.type = typeAward,
    this.awardedOn,
    this.work,
    this.members = const [],
    this.note,
    this.sourceUrl,
  });

  static const typeAward = 'award';
  static const typeMusicShow = 'music-show';
  static const typeMilestone = 'milestone';

  /// Stable, unique identifier.
  final String id;

  /// The category or name of the achievement, e.g. `Best New Artist`.
  final String title;

  /// Who gave it: a ceremony, a music show, or a platform.
  final String ceremony;

  /// The year it was received — the grouping key.
  ///
  /// A year rather than a full date on purpose: most sources publish only the
  /// year, and inventing a day would state something they never said
  /// (docs/specs/awards.md §4).
  final int year;

  /// One of [typeAward], [typeMusicShow], [typeMilestone].
  final String type;

  /// The exact date, on the rare occasions it is actually known.
  final DateTime? awardedOn;

  /// The song or album it was for, e.g. `RUDE!`.
  final String? work;

  /// The members it went to, when the achievement is individual rather than
  /// group-wide. Empty means the whole group.
  final List<String> members;

  /// Extra context, e.g. `March 2025` or `Second win`.
  final String? note;

  /// Link to an official source (stored; opening it needs a valid https URL).
  final String? sourceUrl;

  /// Whether this went to specific members rather than the whole group.
  bool get isIndividual => members.isNotEmpty;
}
