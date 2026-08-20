import '../data/http_voting_repository.dart';

/// What to say about a failed load, told apart by what actually went wrong.
///
/// A `voting.json` we cannot read is a fault in the data we publish, not in
/// the reader's connection — sending them to check their signal points them at
/// something they have no way to fix, and hides the fault from us.
/// [HttpVotingRepository.parseCampaigns] surfaces bad data as a
/// [FormatException] (not an array, a non-`https` url) or a [TypeError] (a
/// required field missing); anything else — a timeout, a dead host, a non-200 —
/// really is the network.
///
/// It sits in its own file rather than inside the Voting Hub page because the
/// Agenda reports the same failure in its own way and must not answer it
/// differently (docs/specs/agenda.md §5).
String votingErrorMessage(Object error) {
  if (error is FormatException || error is TypeError) {
    return "Couldn't read the voting list.\nThe problem is on our side, not your connection.";
  }
  return "Couldn't reach the votes.\nCheck your connection.";
}
