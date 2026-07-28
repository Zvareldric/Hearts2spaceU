import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/app/widgets/states/empty_view.dart';
import 'package:hearts2spaceu/app/widgets/states/error_view.dart';
import 'package:hearts2spaceu/features/latest_updates/domain/update.dart';
import 'package:hearts2spaceu/features/latest_updates/domain/update_repository.dart';
import 'package:hearts2spaceu/features/latest_updates/presentation/pages/latest_updates_page.dart';
import 'package:hearts2spaceu/features/latest_updates/presentation/pages/update_detail_page.dart';
import 'package:hearts2spaceu/features/latest_updates/presentation/providers/update_providers.dart';
import 'package:hearts2spaceu/features/latest_updates/presentation/widgets/update_card.dart';
import 'package:hearts2spaceu/routes/app_router.dart';

class _FakeUpdateRepository implements UpdateRepository {
  _FakeUpdateRepository(this.updates);

  final List<Update> updates;

  @override
  Future<List<Update>> getUpdates() async => updates;
}

class _ThrowingUpdateRepository implements UpdateRepository {
  @override
  Future<List<Update>> getUpdates() async => throw Exception('offline');
}

class _DelayedUpdateRepository implements UpdateRepository {
  _DelayedUpdateRepository(this.updates);

  final List<Update> updates;

  @override
  Future<List<Update>> getUpdates() =>
      Future.delayed(const Duration(seconds: 1), () => updates);
}

/// Fails the first call, then succeeds — to exercise Retry, which matters more
/// here than anywhere else: network failures really are transient.
class _FlakyUpdateRepository implements UpdateRepository {
  _FlakyUpdateRepository(this.updates);

  final List<Update> updates;
  bool _firstAttempt = true;

  @override
  Future<List<Update>> getUpdates() async {
    if (_firstAttempt) {
      _firstAttempt = false;
      throw Exception('offline');
    }
    return updates;
  }
}

Widget _app(UpdateRepository repository) {
  return ProviderScope(
    overrides: [updateRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(
      onGenerateRoute: AppRouter.onGenerateRoute,
      home: const LatestUpdatesPage(),
    ),
  );
}

List<Update> _updates() => [
  Update(
    id: 'u1',
    title: 'Alpha News',
    publishedAt: DateTime(2026, 7, 5),
    summary: 'Alpha summary.',
    body: 'Alpha body.',
    category: 'announcement',
  ),
  Update(id: 'u2', title: 'Beta News', publishedAt: DateTime(2026, 6, 1)),
];

void main() {
  testWidgets('Loading — shows a spinner while fetching', (tester) async {
    await tester.pumpWidget(_app(_DelayedUpdateRepository(const [])));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  });

  testWidgets('Data — shows a card per update, newest first', (tester) async {
    await tester.pumpWidget(_app(_FakeUpdateRepository(_updates())));
    await tester.pumpAndSettle();

    expect(find.byType(UpdateCard), findsNWidgets(2));

    // Newest first: Alpha (July) must render above Beta (June).
    final alphaY = tester.getTopLeft(find.text('Alpha News')).dy;
    final betaY = tester.getTopLeft(find.text('Beta News')).dy;
    expect(alphaY, lessThan(betaY));
  });

  testWidgets('Empty — shows the empty state when there are no updates', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_FakeUpdateRepository(const [])));
    await tester.pumpAndSettle();

    expect(find.byType(EmptyView), findsOneWidget);
    expect(find.text('No updates yet.'), findsOneWidget);
  });

  testWidgets('Error — shows the error state when the fetch fails', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_ThrowingUpdateRepository()));
    await tester.pumpAndSettle();

    expect(find.byType(ErrorView), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('Retry — Error → Retry → Data', (tester) async {
    await tester.pumpWidget(_app(_FlakyUpdateRepository(_updates())));
    await tester.pumpAndSettle();

    expect(find.byType(ErrorView), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.byType(ErrorView), findsNothing);
    expect(find.byType(UpdateCard), findsNWidgets(2));
  });

  testWidgets('Navigation — List → Detail → Back', (tester) async {
    await tester.pumpWidget(_app(_FakeUpdateRepository(_updates())));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Alpha News'));
    await tester.pumpAndSettle();

    expect(find.byType(UpdateDetailPage), findsOneWidget);
    expect(find.text('Alpha body.'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.byType(LatestUpdatesPage), findsOneWidget);
  });
}
