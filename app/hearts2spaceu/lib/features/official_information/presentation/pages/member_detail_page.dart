import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/member.dart';
import '../providers/member_providers.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';

/// UC-2 — one member's details.
///
/// Reuses the cached [membersProvider] (no refetch) and selects by id, which
/// also exercises the same Loading/Empty/Error views as the list.
class MemberDetailPage extends ConsumerWidget {
  const MemberDetailPage({super.key, required this.memberId});

  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(membersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Member')),
      body: membersAsync.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          message: 'Failed to load member.',
          onRetry: () => ref.invalidate(membersProvider),
        ),
        data: (members) {
          final matches = members.where((m) => m.id == memberId);
          if (matches.isEmpty) {
            return const EmptyView(message: 'Member not found.');
          }
          return _MemberDetail(member: matches.first);
        },
      ),
    );
  }
}

/// Renders a member's fields.
///
/// Date formatting happens HERE (presentation) — never in the domain or data
/// layers, which only keep the raw [DateTime].
class _MemberDetail extends StatelessWidget {
  const _MemberDetail({required this.member});

  final Member member;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(member.stageName, style: textTheme.headlineSmall),
        const SizedBox(height: 16),
        if (member.fullName != null) _DetailRow('Full name', member.fullName!),
        if (member.birthDate != null)
          _DetailRow('Born', _formatDate(member.birthDate!)),
        if (member.positions.isNotEmpty)
          _DetailRow('Positions', member.positions.join(', ')),
        if (member.officialProfileUrl != null)
          _DetailRow('Official profile', member.officialProfileUrl!),
      ],
    );
  }

  static String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          Text(value),
        ],
      ),
    );
  }
}
