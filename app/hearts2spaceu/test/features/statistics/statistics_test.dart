import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/app/widgets/states/empty_view.dart';
import 'package:hearts2spaceu/app/widgets/states/error_view.dart';
import 'package:hearts2spaceu/features/awards/data/asset_award_repository.dart';
import 'package:hearts2spaceu/features/awards/domain/award.dart';
import 'package:hearts2spaceu/features/awards/domain/award_repository.dart';
import 'package:hearts2spaceu/features/awards/presentation/pages/awards_page.dart';
import 'package:hearts2spaceu/features/awards/presentation/providers/award_providers.dart';
import 'package:hearts2spaceu/features/statistics/domain/career_stats.dart';
import 'package:hearts2spaceu/features/statistics/presentation/pages/statistics_page.dart';
import 'package:hearts2spaceu/features/statistics/presentation/widgets/count_bar.dart';
import 'package:hearts2spaceu/routes/app_router.dart';

Award _award(
  String id, {
  required int year,
  String ceremony = 'Some Awards',
  String type = Award.typeAward,
  String? work,
}) => Award(
  id: id,
  title: id,
  ceremony: ceremony,
  year: year,
  type: type,
  work: work,
);

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
      home: const StatisticsPage(),
    ),
  );
}

void main() {
  group('computeStats', () {
    test('an empty list summarises to nothing, not to zeros worth showing', () {
      final stats = computeStats(const []);

      expect(stats.isEmpty, isTrue);
      expect(stats.total, 0);
      expect(stats.byYear, isEmpty);
      expect(stats.musicShowWinsByWork, isEmpty);
      // Guards the divide-by-zero the bars would otherwise do.
      expect(stats.busiestYearCount, 0);
    });

    test('counts each achievement type separately', () {
      final stats = computeStats([
        _award('a', year: 2026),
        _award('b', year: 2026),
        _award('c', year: 2026, type: Award.typeMusicShow, work: 'RUDE!'),
        _award('d', year: 2026, type: Award.typeMilestone),
      ]);

      expect(stats.total, 4);
      expect(stats.ceremonyAwards, 2);
      expect(stats.musicShowWins, 1);
      expect(stats.milestones, 1);
    });

    test('counts ceremonies and releases as distinct, not as entries', () {
      final stats = computeStats([
        _award('a', year: 2026, ceremony: 'MAMA', work: 'RUDE!'),
        _award('b', year: 2026, ceremony: 'MAMA', work: 'RUDE!'),
        _award('c', year: 2026, ceremony: 'GDA', work: 'FOCUS'),
      ]);

      expect(stats.distinctCeremonies, 2);
      expect(stats.distinctWorks, 2);
    });

    test('an achievement with no release is not counted as one', () {
      final stats = computeStats([
        _award('a', year: 2026),
        _award('b', year: 2026, work: 'FOCUS'),
      ]);

      expect(stats.distinctWorks, 1);
    });

    test('years run most recent first', () {
      final stats = computeStats([
        _award('a', year: 2025),
        _award('b', year: 2026),
        _award('c', year: 2025),
      ]);

      expect(stats.byYear.map((y) => y.year), [2026, 2025]);
      expect(stats.byYear.map((y) => y.count), [1, 2]);
      expect(stats.busiestYearCount, 2);
    });

    test('music-show wins rank by count, with a stable tie-break', () {
      final stats = computeStats([
        _award('a', year: 2026, type: Award.typeMusicShow, work: 'Zebra'),
        _award('b', year: 2026, type: Award.typeMusicShow, work: 'Apple'),
        _award('c', year: 2026, type: Award.typeMusicShow, work: 'Apple'),
        _award('d', year: 2026, type: Award.typeMusicShow, work: 'Melon'),
      ]);

      // Apple leads on count; Zebra and Melon tie and fall back to name order.
      expect(stats.musicShowWinsByWork.map((w) => w.work), [
        'Apple',
        'Melon',
        'Zebra',
      ]);
      expect(stats.musicShowWinsByWork.first.count, 2);
    });

    test('only music-show wins reach the per-release ranking', () {
      // A ceremony award for a song must not inflate its music-show count.
      final stats = computeStats([
        _award('a', year: 2026, work: 'RUDE!'),
        _award('b', year: 2026, type: Award.typeMusicShow, work: 'RUDE!'),
      ]);

      expect(stats.musicShowWinsByWork.single.count, 1);
    });

    test('does not mutate the input list', () {
      final awards = [_award('b', year: 2025), _award('a', year: 2026)];
      final snapshot = List.of(awards);

      computeStats(awards);

      expect(awards, snapshot);
    });
  });

  group('against the real asset', () {
    // Counting from the bundled file rather than asserting hand-written
    // numbers: the PO re-curates awards.json freely, and this stays true.
    testWidgets('every total adds up to what awards.json holds', (
      tester,
    ) async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final awards = await const AssetAwardRepository().getAwards();
      final stats = computeStats(awards);

      expect(stats.total, awards.length);
      expect(
        stats.ceremonyAwards + stats.musicShowWins + stats.milestones,
        awards.length,
      );
      expect(
        stats.byYear.fold<int>(0, (sum, y) => sum + y.count),
        awards.length,
      );
      expect(
        stats.musicShowWinsByWork.fold<int>(0, (sum, w) => sum + w.count),
        awards.where((a) => a.type == Award.typeMusicShow).length,
      );
    });
  });

  group('StatisticsPage', () {
    testWidgets('Empty — says there is nothing recorded, not "0"', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_FakeAwardRepository(const [])));
      await tester.pumpAndSettle();

      expect(find.byType(EmptyView), findsOneWidget);
      expect(find.text('0'), findsNothing);
    });

    testWidgets('Error — shows the error state', (tester) async {
      await tester.pumpWidget(_app(_ThrowingAwardRepository()));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorView), findsOneWidget);
    });

    testWidgets('Data — shows the totals and admits where they come from', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          _FakeAwardRepository([
            _award('a', year: 2026, ceremony: 'MAMA'),
            _award(
              'b',
              year: 2025,
              ceremony: 'Inkigayo',
              type: Award.typeMusicShow,
              work: 'RUDE!',
            ),
          ]),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('2'), findsWidgets); // the headline total
      // Design System V2 shows the totals as four labelled tiles rather than
      // one headline number with a caption.
      expect(find.text('Total achievements'), findsOneWidget);
      expect(find.text('Music show wins'), findsOneWidget);
      expect(find.text('2026'), findsOneWidget);
      expect(find.text('2025'), findsOneWidget);

      // The 2×2 tile grid pushes the rest of the page down, so the wins list
      // and the honesty note now start below the fold — scroll to them rather
      // than assume they are on screen.
      await tester.dragUntilVisible(
        find.text('RUDE!'),
        find.byType(ListView),
        const Offset(0, -100),
      );
      expect(find.text('RUDE!'), findsOneWidget);

      // The honesty note is an acceptance criterion, not decoration.
      await tester.dragUntilVisible(
        find.textContaining('may not be complete'),
        find.byType(ListView),
        const Offset(0, -100),
      );
      expect(find.textContaining('may not be complete'), findsOneWidget);
    });

    testWidgets('UC-3 — tapping a year opens the full Awards list', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(_FakeAwardRepository([_award('a', year: 2026)])),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('2026'));
      await tester.pumpAndSettle();

      expect(find.byType(AwardsPage), findsOneWidget);
    });

    testWidgets('a lone year still draws a full bar', (tester) async {
      // count == max, so the bar must not collapse to nothing.
      await tester.pumpWidget(
        _app(_FakeAwardRepository([_award('a', year: 2026)])),
      );
      await tester.pumpAndSettle();

      final bar = tester.widget<CountBar>(find.byType(CountBar).first);
      expect(bar.count, bar.max);
    });
  });
}
