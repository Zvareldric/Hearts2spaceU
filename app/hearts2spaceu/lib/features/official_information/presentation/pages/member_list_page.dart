import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../routes/app_routes.dart';
import '../providers/member_providers.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/member_card.dart';

/// UC-1 — the list of members.
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
      body: membersAsync.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          message: 'Failed to load members.',
          onRetry: () => ref.invalidate(membersProvider),
        ),
        data: (members) {
          if (members.isEmpty) {
            return const EmptyView(message: 'No members yet.');
          }
          return ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              return MemberCard(
                member: member,
                onTap: () => Navigator.of(
                  context,
                ).pushNamed(AppRoutes.memberDetail, arguments: member.id),
              );
            },
          );
        },
      ),
    );
  }
}
