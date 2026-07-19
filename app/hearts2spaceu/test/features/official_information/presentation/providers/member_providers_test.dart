import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/features/official_information/domain/member.dart';
import 'package:hearts2spaceu/features/official_information/domain/member_repository.dart';
import 'package:hearts2spaceu/features/official_information/presentation/providers/member_providers.dart';

/// A repository that returns a fixed list — the payoff of depending on the
/// interface: we swap the real data source without touching UI or providers.
class _FakeMemberRepository implements MemberRepository {
  _FakeMemberRepository(this._result);

  final List<Member> _result;

  @override
  Future<List<Member>> getMembers() async => _result;
}

class _ThrowingMemberRepository implements MemberRepository {
  @override
  Future<List<Member>> getMembers() async => throw Exception('boom');
}

void main() {
  test('membersProvider resolves to the repository result', () async {
    final container = ProviderContainer(
      overrides: [
        memberRepositoryProvider.overrideWithValue(
          _FakeMemberRepository(const [Member(id: 'm1', stageName: 'Alpha')]),
        ),
      ],
    );
    addTearDown(container.dispose);

    final members = await container.read(membersProvider.future);

    expect(members, hasLength(1));
    expect(members.single.stageName, 'Alpha');
  });

  test('membersProvider surfaces repository errors', () async {
    final container = ProviderContainer(
      overrides: [
        memberRepositoryProvider.overrideWithValue(_ThrowingMemberRepository()),
      ],
    );
    addTearDown(container.dispose);

    // Keep the provider alive and let its async computation settle, then
    // assert it carries the error. (Avoids `.future`, which stays pending for
    // an errored provider that nobody awaits.)
    container.listen(membersProvider, (_, _) {}, fireImmediately: true);
    await Future<void>.delayed(Duration.zero);

    final state = container.read(membersProvider);
    expect(state.hasError, isTrue);
    expect(state.error, isA<Exception>());
  });
}
