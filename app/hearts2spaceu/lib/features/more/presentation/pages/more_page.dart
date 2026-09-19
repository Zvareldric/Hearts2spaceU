import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/cards/capability_card.dart';
import '../../../../app/widgets/glass/glass_nav_bar.dart';
import '../../../../app/widgets/layout/staggered_item.dart';
import '../../../../routes/app_routes.dart';

/// The fifth tab — every capability that isn't one of the four in the nav bar.
///
/// Pure navigation: no state, no providers, no domain of its own. Each tile
/// pushes an existing route, so this page holds no knowledge a feature already
/// owns.
class MorePage extends StatelessWidget {
  const MorePage({super.key});

  /// Order is by expected use, not alphabetical — Members and Music are what
  /// most fans came for.
  static const _entries =
      <
        ({
          IconData icon,
          String title,
          String subtitle,
          List<Color> gradient,
          String route,
        })
      >[
        (
          icon: Icons.groups_rounded,
          title: 'Members',
          subtitle: 'Meet Hearts2Hearts',
          gradient: CapabilityGradients.members,
          route: AppRoutes.memberList,
        ),
        // One door for one capability: the releases are what Music is, and the
        // official channels sit one tap inside it rather than as a second tile
        // competing for the same word (docs/specs/discography.md §7).
        (
          icon: Icons.music_note_rounded,
          title: 'Music',
          subtitle: 'Releases & platforms',
          gradient: CapabilityGradients.music,
          route: AppRoutes.discography,
        ),
        (
          icon: Icons.insights_rounded,
          title: 'Statistics',
          subtitle: 'Their record so far',
          gradient: CapabilityGradients.statistics,
          route: AppRoutes.statistics,
        ),
        (
          icon: Icons.newspaper_rounded,
          title: 'Latest Updates',
          subtitle: 'News & announcements',
          gradient: CapabilityGradients.updates,
          route: AppRoutes.latestUpdates,
        ),
        (
          icon: Icons.emoji_events_rounded,
          title: 'Awards',
          subtitle: 'What they have won',
          gradient: CapabilityGradients.awards,
          route: AppRoutes.awards,
        ),
        (
          icon: Icons.how_to_vote_rounded,
          title: 'Voting',
          subtitle: 'Support the group',
          gradient: CapabilityGradients.voting,
          route: AppRoutes.voting,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      // Rows of two rather than a grid: a grid cell's height is derived from
      // its width through a fixed aspect ratio, so it cannot grow when the text
      // inside it does. At 390dp that ratio was already half a pixel short for a
      // card whose subtitle wraps to two lines — at ordinary text size — and it
      // could never have held 200%. Each row here is as tall as its tallest
      // card, and both cards in a row stretch to match, so the menu keeps its
      // even rhythm at any text size.
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.sm,
          AppSpacing.screenPadding,
          // Clear the floating nav bar, which this list scrolls underneath.
          GlassNavBar.reservedSpace,
        ),
        children: [
          for (var i = 0; i < _entries.length; i += 2)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: _card(context, i)),
                    const SizedBox(width: AppSpacing.md),
                    // An odd last entry keeps its half width rather than
                    // stretching across the row.
                    Expanded(
                      child: i + 1 < _entries.length
                          ? _card(context, i + 1)
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, int index) {
    final entry = _entries[index];
    return StaggeredItem(
      index: index,
      child: CapabilityCard(
        icon: entry.icon,
        title: entry.title,
        subtitle: entry.subtitle,
        gradient: entry.gradient,
        onTap: () => Navigator.of(context).pushNamed(entry.route),
      ),
    );
  }
}
