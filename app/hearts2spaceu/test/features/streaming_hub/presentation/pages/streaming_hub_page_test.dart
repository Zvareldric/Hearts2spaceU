import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/app/widgets/states/empty_view.dart';
import 'package:hearts2spaceu/app/widgets/states/error_view.dart';
import 'package:hearts2spaceu/features/streaming_hub/domain/official_platform.dart';
import 'package:hearts2spaceu/features/streaming_hub/domain/platform_repository.dart';
import 'package:hearts2spaceu/features/streaming_hub/presentation/pages/streaming_hub_page.dart';
import 'package:hearts2spaceu/features/streaming_hub/presentation/providers/platform_providers.dart';
import 'package:hearts2spaceu/features/streaming_hub/presentation/widgets/platform_card.dart';
import 'package:hearts2spaceu/shared/services/url_opener.dart';

class _FakePlatformRepository implements PlatformRepository {
  _FakePlatformRepository(this.platforms);

  final List<OfficialPlatform> platforms;

  @override
  Future<List<OfficialPlatform>> getPlatforms() async => platforms;
}

class _ThrowingPlatformRepository implements PlatformRepository {
  @override
  Future<List<OfficialPlatform>> getPlatforms() async =>
      throw Exception('bad asset');
}

/// Records what it was asked to open instead of launching anything — the whole
/// reason UrlOpener sits behind a provider.
class _RecordingUrlOpener implements UrlOpener {
  _RecordingUrlOpener({this.succeeds = true});

  final bool succeeds;
  final opened = <String>[];

  @override
  Future<bool> open(String url) async {
    opened.add(url);
    return succeeds;
  }
}

Widget _app(PlatformRepository repository, {UrlOpener? urlOpener}) {
  return ProviderScope(
    overrides: [
      platformRepositoryProvider.overrideWithValue(repository),
      if (urlOpener != null) urlOpenerProvider.overrideWithValue(urlOpener),
    ],
    child: const MaterialApp(home: StreamingHubPage()),
  );
}

List<OfficialPlatform> _platforms() => const [
  OfficialPlatform(
    id: 'spotify',
    name: 'Spotify',
    url: 'https://open.spotify.com/artist/abc',
    category: 'music',
  ),
  OfficialPlatform(
    id: 'instagram',
    name: 'Instagram',
    url: 'https://www.instagram.com/hearts2hearts',
    category: 'social',
    handle: '@hearts2hearts',
  ),
];

void main() {
  testWidgets('Data — shows a card per platform, grouped by category', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_FakePlatformRepository(_platforms())));
    await tester.pumpAndSettle();

    expect(find.byType(PlatformCard), findsNWidgets(2));
    expect(find.text('LISTEN'), findsOneWidget);
    expect(find.text('FOLLOW'), findsOneWidget);
    expect(find.text('@hearts2hearts'), findsOneWidget);
  });

  testWidgets('Empty — shows the empty state when there are no platforms', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_FakePlatformRepository(const [])));
    await tester.pumpAndSettle();

    expect(find.byType(EmptyView), findsOneWidget);
  });

  testWidgets('Error — shows the error state when loading fails', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_ThrowingPlatformRepository()));
    await tester.pumpAndSettle();

    expect(find.byType(ErrorView), findsOneWidget);
  });

  testWidgets('Tap — opens the platform URL', (tester) async {
    final opener = _RecordingUrlOpener();
    await tester.pumpWidget(
      _app(_FakePlatformRepository(_platforms()), urlOpener: opener),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Spotify'));
    await tester.pumpAndSettle();

    expect(opener.opened, ['https://open.spotify.com/artist/abc']);
  });

  testWidgets('Tap failure — tells the user instead of doing nothing', (
    tester,
  ) async {
    final opener = _RecordingUrlOpener(succeeds: false);
    await tester.pumpWidget(
      _app(_FakePlatformRepository(_platforms()), urlOpener: opener),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Spotify'));
    await tester.pump(); // let the SnackBar appear

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining("Couldn't open"), findsOneWidget);
  });
}
