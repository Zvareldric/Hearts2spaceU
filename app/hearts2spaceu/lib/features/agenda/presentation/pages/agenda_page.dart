import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_motion.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/cards/app_card.dart';
import '../../../../app/widgets/glass/glass_nav_bar.dart';
import '../../../../app/widgets/layout/page_heading.dart';
import '../../../../app/widgets/layout/section_header.dart';
import '../../../../app/widgets/layout/staggered_item.dart';
import '../../../../app/widgets/states/empty_view.dart';
import '../../../../app/widgets/states/error_view.dart';
import '../../../../app/widgets/states/loading_view.dart';
import '../../../../routes/app_routes.dart';
import '../../../../shared/services/url_opener.dart';
import '../../../schedule/presentation/providers/event_providers.dart';
import '../../../voting/presentation/providers/voting_providers.dart';
import '../../../voting/presentation/voting_error_message.dart';
import '../../domain/agenda_item.dart';
import '../../domain/build_agenda.dart';
import '../providers/agenda_providers.dart';
import '../widgets/agenda_row.dart';

/// UC-1 & UC-2 — everything time-bound in one list, soonest deadline first.
///
/// Schedule answers "when is it"; Voting answers "what can I support"; this
/// page answers "what first" (docs/specs/agenda.md §1). It owns no data: the
/// merging and grouping are pure functions, and both lists come from the
/// providers their own features already expose.
class AgendaPage extends ConsumerWidget {
  const AgendaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agendaAsync = ref.watch(agendaProvider);
    // Read on its own because the votes failing is not the page failing: the
    // events are still worth showing, and a lost deadline is exactly what this
    // page exists to prevent, so it is said out loud (docs/specs/agenda.md §5).
    final votesError = ref.watch(openVotesProvider).error;

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
              child: PageHeading.sub(title: 'Agenda'),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: AppMotion.of(context, AppMotion.base),
                child: agendaAsync.when(
                  loading: () => const LoadingView(key: ValueKey('loading')),
                  // Events come from a bundled asset: if they cannot be read,
                  // the page has no backbone left to show.
                  error: (error, _) => ErrorView(
                    key: const ValueKey('error'),
                    message: "Couldn't load the schedule.",
                    onRetry: () => ref.invalidate(upcomingEventsProvider),
                  ),
                  data: (items) {
                    if (items.isEmpty && votesError == null) {
                      // Between comebacks and outside award season this is the
                      // right state, not a broken one.
                      return const EmptyView(
                        key: ValueKey('empty'),
                        message:
                            'Nothing scheduled yet.\nUpcoming events and open votes will show up here.',
                        icon: Icons.event_available_rounded,
                      );
                    }
                    return _AgendaList(
                      key: const ValueKey('data'),
                      items: items,
                      votesError: votesError,
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

class _AgendaList extends ConsumerWidget {
  const _AgendaList({super.key, required this.items, this.votesError});

  final List<AgendaItem> items;
  final Object? votesError;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // One `now` for the whole list, so the grouping and every countdown in it
    // agree with each other.
    final now = DateTime.now();
    final groups = groupByProximity(items, now);
    var animationIndex = 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        0,
        AppSpacing.screenPadding,
        // Clear the floating nav bar this list can scroll underneath.
        GlassNavBar.reservedSpace,
      ),
      children: [
        if (votesError case final error?) ...[
          _VotesUnavailable(error: error),
          const SizedBox(height: AppSpacing.lg),
        ],
        // Only reachable with the notice above: an empty list on its own is
        // the EmptyView, and saying "nothing scheduled" while half the sources
        // failed would be a guess dressed up as an answer.
        if (items.isEmpty)
          const EmptyView(
            message: 'No upcoming events either.',
            icon: Icons.event_available_rounded,
          ),
        for (final group in groups) ...[
          SectionHeader(label: _label(group.proximity)),
          const SizedBox(height: AppSpacing.sm),
          for (final item in group.items)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: StaggeredItem(
                index: animationIndex++,
                child: AgendaRow(
                  item: item,
                  now: now,
                  onTap: _onTap(context, ref, item),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ],
    );
  }

  /// Where a row leads: an event to its detail page, a vote to the organiser's
  /// platform. A vote that has not opened yet leads nowhere — the same rule the
  /// Voting Hub follows, so it cannot look like it is already running.
  VoidCallback? _onTap(BuildContext context, WidgetRef ref, AgendaItem item) {
    return switch (item.kind) {
      AgendaKind.event => () => Navigator.of(
        context,
      ).pushNamed(AppRoutes.eventDetail, arguments: item.id),
      AgendaKind.vote when !item.isUpcomingVote => () => _open(
        context,
        ref,
        item,
      ),
      AgendaKind.vote => null,
    };
  }

  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    AgendaItem item,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final opened = await ref.read(urlOpenerProvider).open(item.url!);

    if (!opened) {
      messenger.showSnackBar(
        SnackBar(
          content: Text("Couldn't open ${item.subtitle ?? item.title}."),
        ),
      );
    }
  }

  static String _label(AgendaProximity proximity) => switch (proximity) {
    AgendaProximity.today => 'Today',
    AgendaProximity.thisWeek => 'This week',
    AgendaProximity.later => 'Later',
  };
}

/// The votes could not be loaded — said in one small line, with a way to try
/// again, above the events that did load.
///
/// Deliberately louder than Home's announcement card, which disappears without
/// a sound when its feed fails (docs/design-system-v2.md §8). Home is a teaser;
/// this page is nothing but deadlines, and a deadline that quietly goes missing
/// would be read as "there are none" when the truth is "we don't know".
class _VotesUnavailable extends ConsumerWidget {
  const _VotesUnavailable({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, size: 20, color: AppColors.error),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              // The same sentence the Voting Hub would say, from the same
              // function, so the two never disagree about whose fault it is.
              votingErrorMessage(error),
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: AppColors.inkMuted),
            ),
          ),
          TextButton(
            onPressed: () => ref.invalidate(openVotesProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
