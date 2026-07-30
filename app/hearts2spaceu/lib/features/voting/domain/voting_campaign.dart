/// An official vote fans can take part in.
///
/// The app links out to the organiser's platform; it never collects votes
/// itself (docs/specs/voting-hub.md §2).
class VotingCampaign {
  const VotingCampaign({
    required this.id,
    required this.title,
    required this.organizer,
    required this.url,
    required this.closesAt,
    this.opensAt,
    this.note,
  });

  final String id;

  /// The category being voted on, e.g. `Best Female Group`.
  final String title;

  /// Who runs it, e.g. `MAMA Awards`.
  final String organizer;

  /// Official voting link. Always `https` — enforced when parsing.
  final String url;

  /// Required: without a deadline an expired vote could never be hidden.
  final DateTime closesAt;

  /// When voting starts, if it has not opened yet.
  final DateTime? opensAt;

  final String? note;

  /// True while the vote is announced but not yet open.
  bool isUpcomingAt(DateTime now) => opensAt != null && now.isBefore(opensAt!);
}
