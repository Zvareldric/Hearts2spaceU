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
import '../providers/update_providers.dart';
import '../widgets/update_card.dart';

/// UC-1 — official news, newest first.
///
/// Presentation only: it watches [latestUpdatesProvider] and renders the
/// matching state. Fetching and ordering live in the provider and the pure
/// `latestFirst`.
class LatestUpdatesPage extends ConsumerWidget {
  const LatestUpdatesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updatesAsync = ref.watch(latestUpdatesProvider);

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
              child: PageHeading.sub(title: 'Latest Updates'),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: AppMotion.of(context, AppMotion.base),
                child: updatesAsync.when(
                  loading: () => const LoadingView(key: ValueKey('loading')),
                  error: (error, _) => ErrorView(
                    key: const ValueKey('error'),
                    message:
                        "Couldn't reach the updates.\nCheck your connection.",
                    onRetry: () => ref.invalidate(latestUpdatesProvider),
                  ),
                  data: (updates) {
                    if (updates.isEmpty) {
                      return const EmptyView(
                        key: ValueKey('empty'),
                        message: 'No updates yet.',
                        icon: Icons.newspaper_rounded,
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
                      itemCount: updates.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final update = updates[index];
                        return StaggeredItem(
                          index: index,
                          child: UpdateCard(
                            update: update,
                            onTap: () => Navigator.of(context).pushNamed(
                              AppRoutes.updateDetail,
                              arguments: update.id,
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
