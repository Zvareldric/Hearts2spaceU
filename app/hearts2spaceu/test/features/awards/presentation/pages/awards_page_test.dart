import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/app/widgets/states/empty_view.dart';
import 'package:hearts2spaceu/app/widgets/states/error_view.dart';
import 'package:hearts2spaceu/features/awards/domain/award.dart';
import 'package:hearts2spaceu/features/awards/domain/award_repository.dart';
import 'package:hearts2spaceu/features/awards/presentation/pages/award_detail_page.dart';
import 'package:hearts2spaceu/features/awards/presentation/pages/awards_page.dart';
import 'package:hearts2spaceu/features/awards/presentation/providers/award_providers.dart';
import 'package:hearts2spaceu/features/awards/presentation/widgets/award_card.dart';
import 'package:hearts2spaceu/routes/app_router.dart';

class _FakeAwardRepository implements AwardRepository {
  _FakeAwardRepository(this.awards);

  final List<Award> awards;

  @override
  Future<List<Award>> getAwards() async => awards;
}

class _ThrowingAwardRepository implements AwardRepository {
  @override
  Future<List<Award>> getAwards() async => throw Exception('bad asset');
}

Widget _app(AwardRepository repository) {
  return ProviderScope(
    overrides: [awardRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(
      onGenerateRoute: AppRouter.onGenerateRoute,
      home: const AwardsPage(),
    ),
  );
}

List<Award> _awards() => const [
  Award(
    id: 'gda-2026',
    title: 'Most Popular Artist',
    ceremony: 'Golden Disc Awards',
    year: 2026,
  ),
  Award(
    id: 'rude-inkigayo',
    title: '1st Place',
    ceremony: 'Inkigayo',
    year: 2026,
    type: Award.typeMusicShow,
    work: 'RUDE!',
  ),
  Award(
    id: 'kgma-2025-carmen',
    title: 'Individual Trend of May Rookie',
    ceremony: 'KGMA',
    year: 2025,
    members: ['Carmen'],
  ),
];

void main() {
  testWidgets('Data — shows a card per award, grouped by year newest first', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_FakeAwardRepository(_awards())));
    await tester.pumpAndSettle();

    expect(find.byType(AwardCard), findsNWidgets(3));
    expect(find.text('2026'), findsOneWidget);
    expect(find.text('2025'), findsOneWidget);

    // 2026 must render above 2025.
    expect(
      tester.getTopLeft(find.text('2026')).dy,
      lessThan(tester.getTopLeft(find.text('2025')).dy),
    );
  });

  testWidgets('shows the member for an individual achievement', (tester) async {
    await tester.pumpWidget(_app(_FakeAwardRepository(_awards())));
    await tester.pumpAndSettle();

    expect(find.textContaining('Carmen'), findsOneWidget);
  });

  testWidgets('badges only the non-award types', (tester) async {
    await tester.pumpWidget(_app(_FakeAwardRepository(_awards())));
    await tester.pumpAndSettle();

    // The music-show entry is badged; plain awards are not, so the badge does
    // not become visual noise on the majority of the list.
    // TypeBadge renders an unmapped type uppercased, with hyphens opened up —
    // so `music-show` shows as "MUSIC SHOW".
    expect(find.text('MUSIC SHOW'), findsOneWidget);
    expect(find.text(Award.typeAward.toUpperCase()), findsNothing);
  });

  testWidgets('Empty — shows the empty state when there are no awards', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_FakeAwardRepository(const [])));
    await tester.pumpAndSettle();

    expect(find.byType(EmptyView), findsOneWidget);
  });

  testWidgets('Error — shows the error state when loading fails', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_ThrowingAwardRepository()));
    await tester.pumpAndSettle();

    expect(find.byType(ErrorView), findsOneWidget);
  });

  testWidgets('Navigation — List → Detail → Back', (tester) async {
    await tester.pumpWidget(_app(_FakeAwardRepository(_awards())));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Most Popular Artist'));
    await tester.pumpAndSettle();

    expect(find.byType(AwardDetailPage), findsOneWidget);
    expect(find.text('Golden Disc Awards'), findsWidgets);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.byType(AwardsPage), findsOneWidget);
  });
}
