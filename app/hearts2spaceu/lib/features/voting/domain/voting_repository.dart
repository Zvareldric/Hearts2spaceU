import 'voting_campaign.dart';

/// Contract for retrieving voting campaigns.
abstract interface class VotingRepository {
  /// Loads every campaign. Throws if the source cannot be reached or parsed.
  Future<List<VotingCampaign>> getCampaigns();
}
