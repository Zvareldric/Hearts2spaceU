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
import '../member_palette.dart';
import '../providers/member_providers.dart';
import '../widgets/member_card.dart';

/// UC-1 — the members, as a two-column grid of avatar tiles (Design System V2).
///
/// Presentation only: it watches [membersProvider] and renders the matching
/// state. Data loading lives entirely in the provider/repository.
///
/// The heading sits outside the scroll view, not inside it: without an AppBar
/// the round back button is the only way out, so it has to stay on screen in
/// every state — including while loading and after a failure.
class MemberListPage extends ConsumerWidget {
  const MemberListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(membersProvider);

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
              child: PageHeading.sub(title: 'Members'),
            ),
            Expanded(
              // Cross-fades between loading/empty/error/data instead of
              // snapping.
              child: AnimatedSwitcher(
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
                    // Hoisted out of itemBuilder: `memberColor` ranks an id
                    // against the whole roster, so the roster is the same for
                    // every tile.
                    final ids = members.map((m) => m.id).toList();

                    return GridView.builder(
                      key: const ValueKey('data'),
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenPadding,
                        0,
                        AppSpacing.screenPadding,
                        AppSpacing.xl,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: AppSpacing.md,
                            mainAxisSpacing: AppSpacing.md,
                            // Avatar plus two lines of text, with headroom for
                            // large text settings — tiles hug their content
                            // instead of leaving a pool of empty glass.
                            childAspectRatio: 1.05,
                          ),
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        final member = members[index];
                        return StaggeredItem(
                          index: index,
                          child: MemberCard(
                            member: member,
                            color: memberColor(member.id, ids),
                            onTap: () => Navigator.of(context).pushNamed(
                              AppRoutes.memberDetail,
                              arguments: member.id,
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
