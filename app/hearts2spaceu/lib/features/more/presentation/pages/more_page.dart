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
        (
          icon: Icons.album_rounded,
          title: 'Discography',
          subtitle: 'Every release & track',
          gradient: CapabilityGradients.discography,
          route: AppRoutes.discography,
        ),
        (
          icon: Icons.music_note_rounded,
          title: 'Music',
          subtitle: 'Official platforms',
          gradient: CapabilityGradients.music,
          route: AppRoutes.streamingHub,
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
      body: GridView.builder(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.sm,
          AppSpacing.screenPadding,
          // Clear the floating nav bar, which this list scrolls underneath.
          GlassNavBar.reservedSpace,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          // Icon tile + title + a two-line subtitle, with room for large text
          // settings before anything has to ellipsize.
          childAspectRatio: 1.15,
        ),
        itemCount: _entries.length,
        itemBuilder: (context, index) {
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
        },
      ),
    );
  }
}
