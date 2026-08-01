import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_motion.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/layout/page_heading.dart';
import '../../../../app/widgets/layout/staggered_item.dart';
import '../../../../app/widgets/states/empty_view.dart';
import '../../../../app/widgets/states/error_view.dart';
import '../../../../app/widgets/states/loading_view.dart';
import '../../../../shared/services/url_opener.dart';
import '../../domain/voting_campaign.dart';
import '../providers/voting_providers.dart';
import '../widgets/voting_card.dart';

/// UC-1 & UC-2 — the votes worth acting on, each a way out to the organiser's
/// official platform.
class VotingHubPage extends ConsumerWidget {
  const VotingHubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final votesAsync = ref.watch(openVotesProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.lg,
                AppSpacing.screenPadding,
                0,
              ),
              child: PageHeading.sub(title: 'Voting'),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: AppMotion.of(context, AppMotion.base),
                child: votesAsync.when(
                  loading: () => const LoadingView(key: ValueKey('loading')),
                  error: (error, _) => ErrorView(
                    key: const ValueKey('error'),
                    message:
                        "Couldn't reach the votes.\nCheck your connection.",
                    onRetry: () => ref.invalidate(openVotesProvider),
                  ),
                  data: (votes) {
                    if (votes.isEmpty) {
                      // Off-season is the normal state, not a failure — say so.
                      return const EmptyView(
                        key: ValueKey('empty'),
                        message:
                            'No votes running right now.\nThey usually open around award season.',
                        icon: Icons.how_to_vote_rounded,
                      );
                    }
                    return _VotingList(
                      key: const ValueKey('data'),
                      votes: votes,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VotingList extends ConsumerWidget {
  const _VotingList({super.key, required this.votes});

  final List<VotingCampaign> votes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // One `now` for the whole list so every countdown agrees with the others.
    final now = DateTime.now();

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      itemCount: votes.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final campaign = votes[index];
        final upcoming = campaign.isUpcomingAt(now);
        return StaggeredItem(
          index: index,
          child: VotingCard(
            campaign: campaign,
            now: now,
            // A vote that has not opened yet leads nowhere useful, so it is
            // shown but not tappable.
            onTap: upcoming ? null : () => _open(context, ref, campaign),
          ),
        );
      },
    );
  }

  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    VotingCampaign campaign,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final opened = await ref.read(urlOpenerProvider).open(campaign.url);

    if (!opened) {
      messenger.showSnackBar(
        SnackBar(content: Text("Couldn't open ${campaign.organizer}.")),
      );
    }
  }
}
