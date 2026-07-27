import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_motion.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/layout/staggered_item.dart';
import '../../../../app/widgets/states/empty_view.dart';
import '../../../../app/widgets/states/error_view.dart';
import '../../../../app/widgets/states/loading_view.dart';
import '../../../../routes/app_routes.dart';
import '../providers/member_providers.dart';
import '../widgets/member_card.dart';

/// UC-1 — the list of members. Design System V1 (Checkpoint 5).
///
/// Presentation only: it watches [membersProvider] and renders the matching
/// state. Data loading lives entirely in the provider/repository.
class MemberListPage extends ConsumerWidget {
  const MemberListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(membersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Members')),
      // Cross-fades between loading/empty/error/data instead of snapping.
      body: AnimatedSwitcher(
        duration: AppMotion.of(context, AppMotion.base),
        child: membersAsync.when(
          loading: () => const LoadingView(key: ValueKey('loading')),
          error: (error, _) => ErrorView(
            key: const ValueKey('error'),
            message: 'Failed to load members.',
            onRetry: () => ref.invalidate(membersProvider),
          ),
          data: (members) {
            if (members.isEmpty) {
              return const EmptyView(
                key: ValueKey('empty'),
                message: 'No members yet.',
              );
            }
            return ListView.separated(
              key: const ValueKey('data'),
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              itemCount: members.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final member = members[index];
                return StaggeredItem(
                  index: index,
                  child: MemberCard(
                    member: member,
                    onTap: () => Navigator.of(
                      context,
                    ).pushNamed(AppRoutes.memberDetail, arguments: member.id),
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
