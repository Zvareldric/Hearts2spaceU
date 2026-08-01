import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/app/theme/app_theme.dart';
import 'package:hearts2spaceu/features/home/presentation/pages/home_page.dart';
import 'package:hearts2spaceu/features/home/presentation/widgets/hero_update_card.dart';
import 'package:hearts2spaceu/features/latest_updates/domain/update.dart';
import 'package:hearts2spaceu/features/latest_updates/domain/update_repository.dart';
import 'package:hearts2spaceu/features/latest_updates/presentation/providers/update_providers.dart';

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

Update _update(String id, DateTime publishedAt) => Update(
  id: id,
  title: 'Hearts2Hearts announce Japanese debut single',
  publishedAt: publishedAt,
  summary: 'Arriving in August 2026.',
  category: 'Announcement',
);

Future<void> _pumpHome(WidgetTester tester, UpdateRepository repository) async {
  tester.view
    ..physicalSize = const Size(390, 1600)
    ..devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [updateRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(theme: AppTheme.light, home: const HomePage()),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('Home leads with the newest update', (tester) async {
    // Deliberately out of order: the card must show the newest, which is the
    // provider's job — this asserts Home takes the first of the sorted list
    // rather than the first of the raw feed.
    await _pumpHome(
      tester,
      _FakeUpdateRepository([
        _update('older', DateTime(2026, 6, 1)),
        _update('newest', DateTime(2026, 7, 5)),
      ]),
    );

    expect(find.byType(HeroUpdateCard), findsOneWidget);
    expect(
      tester.widget<HeroUpdateCard>(find.byType(HeroUpdateCard)).update.id,
      'newest',
    );
    // The category pill is uppercased for display.
    expect(find.text('ANNOUNCEMENT'), findsOneWidget);
    expect(find.text('Read more'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the slot collapses when the feed cannot be reached', (
    tester,
  ) async {
    // Offline is the common case on a cold start, and this is a teaser: the
    // Latest Updates page owns the error and the Retry. Home just stays quiet.
    await _pumpHome(tester, _ThrowingUpdateRepository());

    expect(find.byType(HeroUpdateCard), findsNothing);
    expect(tester.takeException(), isNull);
    // The rest of Home still renders.
    expect(find.text('Hearts2spaceU'), findsOneWidget);
  });
}
