import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../schedule/presentation/providers/event_providers.dart';
import '../../../voting/domain/voting_campaign.dart';
import '../../../voting/presentation/providers/voting_providers.dart';
import '../../domain/agenda_item.dart';
import '../../domain/build_agenda.dart';

/// The agenda: upcoming events and open votes on one deadline axis.
///
/// It owns no repository and no data file. Both lists already have a provider
/// that loads, filters, and sorts them, so a third one for the same two files
/// would add code without adding capability (ADR-001, docs/04 §4).
///
/// The two sources fail differently, and that difference survives here: events
/// come from a bundled asset, so their failure is the page's failure and is
/// passed through. Votes come over the network, so a failure leaves the events
/// standing — the page reads [openVotesProvider] itself to say so out loud
/// rather than dropping the votes in silence (docs/specs/agenda.md §5).
///
/// While the votes are still in flight the events are shown already, and the
/// votes drop in when they land: the events are bundled and ready at once, and
/// holding them behind a network request would make the fast half wait for the
/// slow one.
final agendaProvider = Provider<AsyncValue<List<AgendaItem>>>((ref) {
  final eventsAsync = ref.watch(upcomingEventsProvider);
  final votes =
      ref.watch(openVotesProvider).asData?.value ?? const <VotingCampaign>[];

  return eventsAsync.whenData(
    (events) => buildAgenda(events: events, votes: votes, now: DateTime.now()),
  );
});
