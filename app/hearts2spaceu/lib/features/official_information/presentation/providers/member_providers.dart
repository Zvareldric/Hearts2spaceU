import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/asset_member_repository.dart';
import '../../domain/member.dart';
import '../../domain/member_repository.dart';

/// Provides the [MemberRepository] implementation.
///
/// The feature depends on this provider — not on a concrete class — so tests
/// can `override` it with a fake repository without touching the UI.
final memberRepositoryProvider = Provider<MemberRepository>((ref) {
  return const AssetMemberRepository();
});

/// Loads the members and exposes them as an [AsyncValue] (loading/data/error).
///
/// Empty is not a separate state here: it is the `data` case where the list
/// happens to be empty — the UI decides how to render that.
final membersProvider = FutureProvider<List<Member>>((ref) {
  final repository = ref.watch(memberRepositoryProvider);
  return repository.getMembers();
});
