import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_motion.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/layout/page_heading.dart';
import '../../../../app/widgets/layout/staggered_item.dart';
import '../../../../app/widgets/states/empty_view.dart';
import '../../../../app/widgets/states/error_view.dart';
import '../../../../app/widgets/states/loading_view.dart';
import '../../../../routes/app_routes.dart';
import '../providers/release_providers.dart';
import '../widgets/release_card.dart';

/// UC-1 — every Hearts2Hearts release, newest first.
///
/// Presentation only: it watches [discographyProvider] and renders the matching
/// state. Loading and ordering live in the provider and the pure `newestFirst`.
class DiscographyPage extends ConsumerWidget {
  const DiscographyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final releasesAsync = ref.watch(discographyProvider);

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
              child: PageHeading.sub(title: 'Discography'),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: AppMotion.of(context, AppMotion.base),
                child: releasesAsync.when(
                  loading: () => const LoadingView(key: ValueKey('loading')),
                  error: (error, _) => ErrorView(
                    key: const ValueKey('error'),
                    message: "Couldn't load the discography.",
                    onRetry: () => ref.invalidate(discographyProvider),
                  ),
                  data: (releases) {
                    if (releases.isEmpty) {
                      return const EmptyView(
                        key: ValueKey('empty'),
                        message: 'No releases recorded yet.',
                        icon: Icons.album_rounded,
                      );
                    }
                    return ListView.separated(
                      key: const ValueKey('data'),
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenPadding,
                        0,
                        AppSpacing.screenPadding,
                        AppSpacing.xl,
                      ),
                      itemCount: releases.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final release = releases[index];
                        return StaggeredItem(
                          index: index,
                          child: ReleaseCard(
                            release: release,
                            onTap: () => Navigator.of(context).pushNamed(
                              AppRoutes.releaseDetail,
                              arguments: release.id,
                            ),
                          ),
                        );
                      },
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
