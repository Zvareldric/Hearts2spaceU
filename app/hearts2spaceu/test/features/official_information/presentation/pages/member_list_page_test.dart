import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/features/official_information/domain/member.dart';
import 'package:hearts2spaceu/features/official_information/domain/member_repository.dart';
import 'package:hearts2spaceu/features/official_information/presentation/pages/member_list_page.dart';
import 'package:hearts2spaceu/features/official_information/presentation/providers/member_providers.dart';
import 'package:hearts2spaceu/features/official_information/presentation/widgets/empty_view.dart';
import 'package:hearts2spaceu/features/official_information/presentation/widgets/error_view.dart';
import 'package:hearts2spaceu/features/official_information/presentation/widgets/member_card.dart';
import 'package:hearts2spaceu/routes/app_router.dart';

class _FakeRepository implements MemberRepository {
  _FakeRepository(this.members);

  final List<Member> members;

  @override
  Future<List<Member>> getMembers() async => members;
}

class _ThrowingRepository implements MemberRepository {
  @override
  Future<List<Member>> getMembers() async => throw Exception('boom');
}

/// Succeeds only after a delay, so the loading state is observable.
class _DelayedRepository implements MemberRepository {
  _DelayedRepository(this.members);

  final List<Member> members;

  @override
  Future<List<Member>> getMembers() =>
      Future.delayed(const Duration(seconds: 1), () => members);
}

/// Fails the first call, then succeeds — to exercise Retry.
class _FlakyRepository implements MemberRepository {
  _FlakyRepository(this.members);

  final List<Member> members;
  bool _firstAttempt = true;

  @override
  Future<List<Member>> getMembers() async {
    if (_firstAttempt) {
      _firstAttempt = false;
      throw Exception('first attempt fails');
    }
    return members;
  }
}

/// Pumps [MemberListPage] as home, with the repository swapped via the
/// interface — every test depends on the contract, never the real data source.
Widget _app(MemberRepository repository) {
  return ProviderScope(
    overrides: [memberRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(
      onGenerateRoute: AppRouter.onGenerateRoute,
      home: const MemberListPage(),
    ),
  );
}

const _members = [
  Member(id: 'm1', stageName: 'Alpha', fullName: 'Alpha Full'),
  Member(id: 'm2', stageName: 'Beta'),
];

void main() {
  testWidgets('Loading — shows a spinner while fetching', (tester) async {
    await tester.pumpWidget(_app(_DelayedRepository(const [])));
    await tester.pump(); // first frame: still within the delay

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Advance past the delay so no timer is left pending at teardown.
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  });

  testWidgets('Data — shows a card per member', (tester) async {
    await tester.pumpWidget(_app(_FakeRepository(_members)));
    await tester.pumpAndSettle();

    expect(find.byType(MemberCard), findsNWidgets(2));
    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('Beta'), findsOneWidget);
  });

  testWidgets('Empty — shows the empty state for no members', (tester) async {
    await tester.pumpWidget(_app(_FakeRepository(const [])));
    await tester.pumpAndSettle();

    expect(find.byType(EmptyView), findsOneWidget);
    expect(find.text('No members yet.'), findsOneWidget);
  });

  testWidgets('Error — shows the error state on failure', (tester) async {
    await tester.pumpWidget(_app(_ThrowingRepository()));
    await tester.pumpAndSettle();

    expect(find.byType(ErrorView), findsOneWidget);
    expect(find.text('Failed to load members.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('Retry — Error → Retry → Data', (tester) async {
    await tester.pumpWidget(_app(_FlakyRepository(_members)));
    await tester.pumpAndSettle();

    expect(find.byType(ErrorView), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.byType(ErrorView), findsNothing);
    expect(find.byType(MemberCard), findsNWidgets(2));
  });

  testWidgets('Navigation — List → Detail → Back', (tester) async {
    await tester.pumpWidget(_app(_FakeRepository(_members)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Alpha'));
    await tester.pumpAndSettle();

    // On the detail page.
    expect(find.text('Member'), findsOneWidget); // detail AppBar title
    expect(find.text('Alpha Full'), findsOneWidget); // fullName

    await tester.pageBack();
    await tester.pumpAndSettle();

    // Back on the list.
    expect(find.byType(MemberListPage), findsOneWidget);
    expect(find.text('Alpha'), findsOneWidget);
  });
}
