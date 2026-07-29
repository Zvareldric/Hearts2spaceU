import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/http_voting_repository.dart';
import '../../domain/open_votes.dart';
import '../../domain/voting_campaign.dart';
import '../../domain/voting_repository.dart';

final votingRepositoryProvider = Provider<VotingRepository>((ref) {
  return HttpVotingRepository();
});

/// Campaigns still worth acting on, soonest deadline first.
final openVotesProvider = FutureProvider<List<VotingCampaign>>((ref) async {
  final campaigns = await ref.watch(votingRepositoryProvider).getCampaigns();
  return openAndUpcoming(campaigns, DateTime.now());
}, retry: (_, _) => null);
