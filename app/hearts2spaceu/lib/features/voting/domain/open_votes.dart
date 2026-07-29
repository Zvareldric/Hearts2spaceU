import 'voting_campaign.dart';

/// Returns the campaigns still worth acting on, soonest deadline first.
///
/// Pure and deterministic: `now` is passed in rather than read from the clock,
/// and [campaigns] is never mutated.
///
/// A closed vote is dropped entirely — its link no longer does anything, and
/// showing a dead action is worse than showing nothing. Unlike the schedule,
/// the cut-off is the exact instant: a vote that closed at 15:00 really is
/// over at 15:01.
List<VotingCampaign> openAndUpcoming(
  List<VotingCampaign> campaigns,
  DateTime now,
) {
  final indexed = <(int, VotingCampaign)>[];
  for (var i = 0; i < campaigns.length; i++) {
    if (!campaigns[i].closesAt.isBefore(now)) {
      indexed.add((i, campaigns[i]));
    }
  }

  indexed.sort((a, b) {
    final byDeadline = a.$2.closesAt.compareTo(b.$2.closesAt);
    return byDeadline != 0 ? byDeadline : a.$1.compareTo(b.$1);
  });

  return [for (final (_, campaign) in indexed) campaign];
}
