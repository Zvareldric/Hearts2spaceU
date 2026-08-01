import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_motion.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/layout/page_heading.dart';
import '../../../../app/widgets/layout/section_header.dart';
import '../../../../app/widgets/layout/staggered_item.dart';
import '../../../../app/widgets/states/empty_view.dart';
import '../../../../app/widgets/states/error_view.dart';
import '../../../../app/widgets/states/loading_view.dart';
import '../../../../shared/services/url_opener.dart';
import '../../domain/official_platform.dart';
import '../providers/platform_providers.dart';
import '../widgets/platform_card.dart';

/// UC-1 & UC-2 — every official channel, grouped, each one a way out of the
/// app and into the official platform.
class StreamingHubPage extends ConsumerWidget {
  const StreamingHubPage({super.key});

  static const _categoryLabels = {
    'music': 'Listen',
    'video': 'Watch',
    'social': 'Follow',
    'community': 'Community',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupedAsync = ref.watch(groupedPlatformsProvider);

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
              child: PageHeading.sub(title: 'Music'),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: AppMotion.of(context, AppMotion.base),
                child: groupedAsync.when(
                  loading: () => const LoadingView(key: ValueKey('loading')),
                  error: (error, _) => ErrorView(
                    key: const ValueKey('error'),
                    message: "Couldn't load the official channels.",
                    onRetry: () => ref.invalidate(groupedPlatformsProvider),
                  ),
                  data: (grouped) {
                    if (grouped.isEmpty) {
                      return const EmptyView(
                        key: ValueKey('empty'),
                        message: 'No official channels yet.',
                        icon: Icons.link_rounded,
                      );
                    }
                    return _PlatformList(
                      key: const ValueKey('data'),
                      grouped: grouped,
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

/// Renders the grouped platforms as sections, flattened into one scroll view.
class _PlatformList extends ConsumerWidget {
  const _PlatformList({super.key, required this.grouped});

  final Map<String, List<OfficialPlatform>> grouped;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // One running index so the entry animation cascades down the whole page,
    // not restarting per section.
    var animationIndex = 0;
    final children = <Widget>[const _LinksOutNote()];

    for (final entry in grouped.entries) {
      children
        ..add(const SizedBox(height: AppSpacing.lg))
        ..add(
          SectionHeader(
            label: StreamingHubPage._categoryLabels[entry.key] ?? entry.key,
          ),
        )
        ..add(const SizedBox(height: AppSpacing.sm));

      for (final platform in entry.value) {
        children
          ..add(
            StaggeredItem(
              index: animationIndex++,
              child: PlatformCard(
                platform: platform,
                onTap: () => _open(context, ref, platform),
              ),
            ),
          )
          ..add(const SizedBox(height: AppSpacing.sm));
      }
      children.removeLast(); // trailing gap of the last card in the section
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        0,
        AppSpacing.screenPadding,
        AppSpacing.xl,
      ),
      children: children,
    );
  }

  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    OfficialPlatform platform,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final opened = await ref.read(urlOpenerProvider).open(platform.url);

    if (!opened) {
      // Tell the user rather than appearing to do nothing.
      messenger.showSnackBar(
        SnackBar(content: Text("Couldn't open ${platform.name}.")),
      );
    }
  }
}

/// States plainly what this page does, since every row leaves the app.
class _LinksOutNote extends StatelessWidget {
  const _LinksOutNote();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Stream Hearts2Hearts on official platforms — Hearts2spaceU links out, '
      'never hosts content itself.',
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: AppColors.inkMuted,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
    );
  }
}
