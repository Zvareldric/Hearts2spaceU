import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_motion.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/layout/staggered_item.dart';
import '../../../../app/widgets/states/empty_view.dart';
import '../../../../app/widgets/states/error_view.dart';
import '../../../../app/widgets/states/loading_view.dart';
import '../../../../routes/app_routes.dart';
import '../providers/update_providers.dart';
import '../widgets/update_card.dart';

/// UC-1 — the list of latest updates. Design System V1.
///
/// Presentation only: it watches [latestUpdatesProvider] and renders the
/// matching state. Fetching and ordering live in the provider and the pure
/// `latestFirst` function.
class LatestUpdatesPage extends ConsumerWidget {
  const LatestUpdatesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updatesAsync = ref.watch(latestUpdatesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Latest Updates')),
      body: AnimatedSwitcher(
        duration: AppMotion.of(context, AppMotion.base),
        child: updatesAsync.when(
          loading: () => const LoadingView(key: ValueKey('loading')),
          error: (error, _) => ErrorView(
            key: const ValueKey('error'),
            // Network failures are the common case here, so the message points
            // at the likely cause rather than blaming the data.
            message: "Couldn't reach the updates.\nCheck your connection.",
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
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              itemCount: updates.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final update = updates[index];
                return StaggeredItem(
                  index: index,
                  child: UpdateCard(
                    update: update,
                    onTap: () => Navigator.of(
                      context,
                    ).pushNamed(AppRoutes.updateDetail, arguments: update.id),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
