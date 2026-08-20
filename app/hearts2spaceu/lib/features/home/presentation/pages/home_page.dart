import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/tab_shell.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_motion.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/cards/app_card.dart';
import '../../../../app/widgets/cards/capability_card.dart';
import '../../../../app/widgets/glass/glass_nav_bar.dart';
import '../../../../app/widgets/layout/section_header.dart';
import '../../../../app/widgets/states/empty_view.dart';
import '../../../../app/widgets/states/error_view.dart';
import '../../../../app/widgets/states/loading_view.dart';
import '../../../../routes/app_routes.dart';
import '../../../discography/presentation/providers/release_providers.dart';
import '../../../discography/presentation/widgets/release_strip.dart';
import '../../../latest_updates/presentation/providers/update_providers.dart';
import '../../../schedule/presentation/providers/event_providers.dart';
import '../../../statistics/presentation/providers/statistics_providers.dart';
import '../widgets/hero_section.dart';
import '../widgets/hero_update_card.dart';
import '../widgets/up_next_card.dart';

/// Landing tab — Design System V2.
///
/// A digest, not a directory: greeting, the newest announcement, four shortcuts,
/// what is happening next, and a way into the numbers. The full list of
/// capabilities moved to the More tab, which is what freed Home to lead with
/// content instead of a nine-card grid.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              MediaQuery.paddingOf(context).top + AppSpacing.lg,
              AppSpacing.screenPadding,
              // Clear the floating nav bar this list scrolls underneath.
              GlassNavBar.reservedSpace,
            ),
            children: const [
              HeroSection(),
              SizedBox(height: AppSpacing.lg),
              _AnnouncementSlot(),
              SizedBox(height: AppSpacing.lg),
              _QuickActions(),
              SizedBox(height: AppSpacing.xl),
              _UpNextSection(),
              SizedBox(height: AppSpacing.xl),
              _DiscographySection(),
              SizedBox(height: AppSpacing.xl),
              _StatsTeaser(),
            ],
          ),
        ),
      ),
    );
  }
}

/// The newest update, as Home's lead card.
///
/// A teaser, so a failure collapses the slot rather than shouting: the Latest
/// Updates tab shows the real error with a Retry, and an error card here would
/// push the whole page down for something the user did not ask to see.
class _AnnouncementSlot extends ConsumerWidget {
  const _AnnouncementSlot();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final update = ref.watch(latestUpdatesProvider).asData?.value.firstOrNull;
    if (update == null) return const SizedBox.shrink();

    return HeroUpdateCard(
      update: update,
      onTap: () => Navigator.of(
        context,
      ).pushNamed(AppRoutes.updateDetail, arguments: update.id),
    );
  }
}

/// Four shortcuts to the capabilities fans reach for most. Everything else,
/// including these four, stays reachable from the More tab.
class _QuickActions extends StatelessWidget {
  const _QuickActions();

  static const _actions =
      <({IconData icon, String label, List<Color> gradient, String route})>[
        (
          icon: Icons.groups_rounded,
          label: 'Members',
          gradient: CapabilityGradients.members,
          route: AppRoutes.memberList,
        ),
        (
          icon: Icons.music_note_rounded,
          label: 'Music',
          gradient: CapabilityGradients.music,
          route: AppRoutes.discography,
        ),
        (
          icon: Icons.insights_rounded,
          label: 'Statistics',
          gradient: CapabilityGradients.statistics,
          route: AppRoutes.statistics,
        ),
        (
          icon: Icons.newspaper_rounded,
          label: 'Updates',
          gradient: CapabilityGradients.updates,
          route: AppRoutes.latestUpdates,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final action in _actions) ...[
          if (action != _actions.first) const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _QuickAction(
              icon: action.icon,
              label: action.label,
              gradient: action.gradient,
              onTap: () => Navigator.of(context).pushNamed(action.route),
            ),
          ),
        ],
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final List<Color> gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.xs,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconTile(icon: icon, gradient: gradient, size: 38),
          const SizedBox(height: AppSpacing.sm),
          // Four across at 360dp leaves each label narrow; scaleDown keeps
          // "Statistics" on one line instead of clipping it.
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.inkSoft,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Home's "Up next" slot — reads [upcomingEventsProvider] and renders the same
/// Loading/Empty/Error/Data states used app-wide, always visible regardless of
/// state (docs/specs/home-layout.md §5).
///
/// Every state uses the compact variant inside an [AppCard], so the slot keeps
/// one fixed height: switching states never reflows the sections below it.
class _UpNextSection extends ConsumerWidget {
  const _UpNextSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(upcomingEventsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeaderRow(
          label: 'Up next',
          // Switches to the Schedule tab instead of pushing a second copy of it
          // over the shell.
          onSeeAll: () => TabSwitcher.go(context, TabShell.scheduleTab),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Cross-fades between states; every state is the same height, so the
        // sections below never move (see up_next_slot_height_test.dart).
        AnimatedSwitcher(
          duration: AppMotion.of(context, AppMotion.base),
          child: eventsAsync.when(
            loading: () => const AppCard(
              key: ValueKey('loading'),
              child: LoadingView(compact: true),
            ),
            error: (error, _) => AppCard(
              key: const ValueKey('error'),
              child: ErrorView(
                message: 'Couldn\'t load the schedule.',
                onRetry: () => ref.invalidate(upcomingEventsProvider),
                compact: true,
              ),
            ),
            data: (events) {
              if (events.isEmpty) {
                return const AppCard(
                  key: ValueKey('empty'),
                  child: EmptyView(
                    message: 'No upcoming events yet.',
                    icon: Icons.event_available_rounded,
                    compact: true,
                  ),
                );
              }
              final next = events.first;
              return UpNextCard(
                key: const ValueKey('data'),
                event: next,
                onTap: () => Navigator.of(
                  context,
                ).pushNamed(AppRoutes.eventDetail, arguments: next.id),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// A section label with a way into the full screen behind it.
class _SectionHeaderRow extends StatelessWidget {
  const _SectionHeaderRow({required this.label, required this.onSeeAll});

  final String label;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: SectionHeader(label: label)),
        TextButton(
          onPressed: onSeeAll,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryStrong,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('See all'),
        ),
      ],
    );
  }
}

/// Their releases, newest first, as a run of covers you can browse by eye.
///
/// Collapses while loading or on failure instead of holding a spinner-shaped
/// hole: it is a browse affordance, and the Discography screen owns the real
/// loading and error states.
class _DiscographySection extends ConsumerWidget {
  const _DiscographySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final releases = ref.watch(discographyProvider).asData?.value ?? const [];
    if (releases.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeaderRow(
          label: 'Discography',
          onSeeAll: () =>
              Navigator.of(context).pushNamed(AppRoutes.discography),
        ),
        const SizedBox(height: AppSpacing.sm),
        ReleaseStrip(
          releases: releases,
          onSelected: (release) => Navigator.of(
            context,
          ).pushNamed(AppRoutes.releaseDetail, arguments: release.id),
        ),
      ],
    );
  }
}

/// A one-line taste of the Statistics page, from the same numbers it shows.
///
/// Hidden until the totals are in: a teaser reading "0 achievements" would be
/// worse than no teaser.
class _StatsTeaser extends ConsumerWidget {
  const _StatsTeaser();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final stats = ref.watch(careerStatsProvider).asData?.value;
    if (stats == null || stats.isEmpty) return const SizedBox.shrink();

    return AppCard(
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.statistics),
      gradient: LinearGradient(
        colors: [
          AppColors.primary.withValues(alpha: 0.40),
          AppColors.secondary.withValues(alpha: 0.35),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SectionHeader(
                  label: 'Fan statistics',
                  color: AppColors.primaryStrong,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${stats.total} achievements · '
                  '${stats.musicShowWins} music show wins so far',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.inkSoft,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.primaryStrong,
            size: 20,
          ),
        ],
      ),
    );
  }
}
