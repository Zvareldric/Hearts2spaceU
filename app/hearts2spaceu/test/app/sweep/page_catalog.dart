import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/app/theme/app_theme.dart';
import 'package:hearts2spaceu/app/widgets/layout/ambient_background.dart';
import 'package:hearts2spaceu/features/gallery/domain/album.dart';
import 'package:hearts2spaceu/features/gallery/domain/gallery_repository.dart';
import 'package:hearts2spaceu/features/gallery/domain/photo.dart';
import 'package:hearts2spaceu/features/gallery/presentation/providers/gallery_providers.dart';
import 'package:hearts2spaceu/features/latest_updates/domain/update.dart';
import 'package:hearts2spaceu/features/latest_updates/domain/update_repository.dart';
import 'package:hearts2spaceu/features/latest_updates/presentation/providers/update_providers.dart';
import 'package:hearts2spaceu/features/schedule/domain/event.dart';
import 'package:hearts2spaceu/features/schedule/domain/event_repository.dart';
import 'package:hearts2spaceu/features/schedule/presentation/providers/event_providers.dart';
import 'package:hearts2spaceu/features/voting/domain/voting_campaign.dart';
import 'package:hearts2spaceu/features/voting/domain/voting_repository.dart';
import 'package:hearts2spaceu/features/voting/presentation/providers/voting_providers.dart';
import 'package:hearts2spaceu/routes/app_router.dart';
import 'package:hearts2spaceu/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Every screen in the app, rendered the way the app renders it.
///
/// The sweeps in this folder — dark mode, text scaling, screen reader — each
/// walk this one list, so a new screen added to the router and to this list is
/// held to all three at once. The alternative, one hand-written test per screen
/// per property, is how a screen ends up checked for contrast but never for
/// 200% text.
///
/// Bundled sources (members, awards, releases, channels) load their real
/// assets, which is the point: the real data is what has to fit. Only the four
/// network sources are replaced, with fixtures that exercise every branch the
/// screens draw — a timed and an all-day event, an open and an announced vote,
/// an update with every optional field.
class SweepPage {
  const SweepPage(this.name, this.route, this.expects, [this.arguments])
    : saved = true;

  /// The same screen with nothing saved, for the states only an empty
  /// collection shows.
  const SweepPage.unsaved(this.name, this.route, this.expects)
    : arguments = null,
      saved = false;

  /// Whether the collection is seeded before the screen renders.
  final bool saved;

  final String name;
  final String route;
  final Object? arguments;

  /// Text that only appears once the screen has its real content.
  ///
  /// A screen stuck on its spinner, or showing "not found" because its data
  /// never arrived, still renders without error — and a sweep would happily
  /// pass it. Release detail did exactly that before this field existed: it
  /// passed every check while showing "Release not found."
  final String expects;

  @override
  String toString() => name;
}

const sweepPages = [
  SweepPage('Home', AppRoutes.home, 'Hearts2spaceU'),
  SweepPage('More', AppRoutes.more, 'Music'),
  SweepPage('Members', AppRoutes.memberList, 'Carmen'),
  SweepPage('Member detail', AppRoutes.memberDetail, 'Choi Ji-woo', 'jiwoo'),
  SweepPage('Schedule', AppRoutes.schedule, 'Magazine Release'),
  SweepPage('Event detail', AppRoutes.eventDetail, 'Tokyo, Japan', _eventId),
  SweepPage('Agenda', AppRoutes.agenda, 'Best Female Group of the Year'),
  SweepPage(
    'Latest updates',
    AppRoutes.latestUpdates,
    'Second mini album Lemon Tang is out now',
  ),
  SweepPage(
    'Update detail',
    AppRoutes.updateDetail,
    'The mini album arrives with a music video for the title track.',
    _updateId,
  ),
  SweepPage('Channels', AppRoutes.streamingHub, 'YouTube'),
  SweepPage('Awards', AppRoutes.awards, '2026'),
  SweepPage(
    'Award detail',
    AppRoutes.awardDetail,
    'Show Champion',
    'lemon-tang-show-champion',
  ),
  SweepPage('Statistics', AppRoutes.statistics, 'Total achievements'),
  SweepPage('Gallery', AppRoutes.gallery, 'FOCUS era'),
  SweepPage('Album', AppRoutes.album, 'FOCUS era', _albumId),
  SweepPage('Photo viewer', AppRoutes.photoViewer, 'Teaser', (_albumId, 0)),
  SweepPage('Collection', AppRoutes.collection, 'Saved members'),
  SweepPage.unsaved(
    'Collection, nothing saved',
    AppRoutes.collection,
    'tap the heart on any Gallery photo',
  ),
  SweepPage('Voting', AppRoutes.voting, 'Rookie of the Year'),
  SweepPage('Music', AppRoutes.discography, 'Moonride'),
  SweepPage(
    'Release detail',
    AppRoutes.releaseDetail,
    'Secret Recipe',
    'lemon-tang',
  ),
];

/// Loads the real Roboto and Material Icons into the test engine.
///
/// The app ships no font of its own, so on Android every word is Roboto. Tests
/// otherwise draw with a placeholder face whose glyphs are boxes the size of the
/// font, which measures text wider than any real typeface — an overflow found
/// in that face might not exist, and one hidden by it might. A layout sweep is
/// only worth running on the metrics a phone uses.
///
/// Read from the Flutter SDK's own font cache. If it cannot be found this
/// throws, deliberately: silently falling back to the placeholder face would
/// turn every result below into a guess.
Future<void> loadRealFonts() async {
  final fonts = _materialFontsDir();

  Future<ByteData> read(String name) async =>
      ByteData.sublistView(await File('${fonts.path}/$name').readAsBytes());

  final roboto = FontLoader('Roboto');
  for (final weight in [
    'Thin',
    'Light',
    'Regular',
    'Medium',
    'Bold',
    'Black',
  ]) {
    roboto.addFont(read('Roboto-$weight.ttf'));
  }
  await roboto.load();

  await (FontLoader(
    'MaterialIcons',
  )..addFont(read('MaterialIcons-Regular.otf'))).load();
}

/// `<flutter>/bin/cache/artifacts/material_fonts`, found by walking up from the
/// test runner binary, which lives inside that same cache.
Directory _materialFontsDir() {
  var dir = File(Platform.resolvedExecutable).parent;
  while (dir.parent.path != dir.path) {
    final candidate = Directory('${dir.path}/artifacts/material_fonts');
    if (candidate.existsSync()) return candidate;
    dir = dir.parent;
  }
  throw StateError(
    'Could not find the Flutter SDK font cache from '
    '${Platform.resolvedExecutable}. Run `flutter precache` and retry.',
  );
}

/// Width of a fixed phrase in the theme's body font — about 223 px in Roboto
/// and 419 px in the test placeholder face. Sweeps assert on it so a harness
/// that silently lost its fonts fails instead of measuring boxes.
Future<double> measureThemeFont(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: const Scaffold(
        body: Center(
          child: Text('Hearts2spaceU', style: TextStyle(fontSize: 32)),
        ),
      ),
    ),
  );
  return tester.getSize(find.text('Hearts2spaceU')).width;
}

const _eventId = 'sweep-tokyo-fansign';
const _updateId = 'sweep-update';
const _albumId = 'sweep-album';

/// Renders [page] exactly as the app would, then settles.
///
/// [textScale] and [size] default to an ordinary phone at ordinary text size;
/// the sweeps turn them up. The ambient wash is included because contrast and
/// layout are only meaningful over the background the app actually paints.
Future<void> pumpSweepPage(
  WidgetTester tester,
  SweepPage page, {
  Brightness brightness = Brightness.light,
  double textScale = 1,
  Size size = const Size(390, 844),
}) async {
  // Seeded so Collection renders its sections rather than its empty state —
  // the empty state is covered by the Collection tests themselves.
  SharedPreferences.setMockInitialValues({
    if (page.saved)
      'favorites': jsonEncode([
        'event:$_eventId',
        'member:jiwoo',
        'update:$_updateId',
        'award:lemon-tang-show-champion',
        'photo:$_albumId/p1',
      ]),
  });

  // `rootBundle` caches the Future of every asset it reads. A Future created
  // inside a previous test's fake-time zone never completes once that test has
  // ended, and every later read of the same file awaited that dead Future —
  // which is why Members rendered alone but hung when run third. Each screen
  // starts from an empty cache and reads its data inside its own test.
  rootBundle.clear();

  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        eventRepositoryProvider.overrideWithValue(_Events()),
        updateRepositoryProvider.overrideWithValue(_Updates()),
        galleryRepositoryProvider.overrideWithValue(_Gallery()),
        votingRepositoryProvider.overrideWithValue(_Votes()),
      ],
      child: MaterialApp(
        theme: brightness == Brightness.dark ? AppTheme.dark : AppTheme.light,
        onGenerateRoute: AppRouter.onGenerateRoute,
        onGenerateInitialRoutes: (_) => [
          AppRouter.onGenerateRoute(
            RouteSettings(name: page.route, arguments: page.arguments),
          ),
        ],
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: AmbientBackground(child: child ?? const SizedBox.shrink()),
        ),
      ),
    ),
  );
  await tester.pump();

  // Bundled data arrives through `rootBundle`, whose read completes on the real
  // event loop — which a widget test, running on fake time, does not turn by
  // itself. Any screen still loading is given real time to finish before fake
  // time takes over again.
  for (var round = 0; round < 50 && _isLoading(); round++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump();
  }
  await tester.pumpAndSettle();

  expect(
    find.textContaining(page.expects),
    findsWidgets,
    reason: '${page.name} never showed its real content',
  );
}

bool _isLoading() =>
    find.byType(CircularProgressIndicator).evaluate().isNotEmpty;

class _Events implements EventRepository {
  @override
  Future<List<Event>> getEvents({bool forceRefresh = false}) async {
    final soon = DateTime.now().add(const Duration(days: 2));
    return [
      Event(
        id: _eventId,
        title: "'ICONIC HEART' Fansign Event in Tokyo Day 1",
        startDateTime: DateTime(soon.year, soon.month, soon.day, 18),
        type: 'fanmeeting',
        location: 'Tokyo, Japan',
        description: 'Offline fansign for the Japanese debut single.',
        officialUrl: 'https://example.com/fansign',
        zoneLabel: 'JST',
        zoneOffset: const Duration(hours: 9),
      ),
      Event(
        id: 'sweep-all-day',
        title: 'Magazine Release',
        startDateTime: DateTime(soon.year, soon.month, soon.day + 1),
        allDay: true,
        type: 'ambassador',
      ),
    ];
  }
}

class _Updates implements UpdateRepository {
  @override
  Future<List<Update>> getUpdates() async => [
    Update(
      id: _updateId,
      title: 'Second mini album Lemon Tang is out now',
      publishedAt: DateTime(2026, 6, 1),
      summary: 'Six tracks, led by the title track Lemon Tang.',
      body: 'The mini album arrives with a music video for the title track.',
      category: 'release',
      sourceUrl: 'https://example.com/lemon-tang',
    ),
  ];
}

class _Gallery implements GalleryRepository {
  @override
  Future<List<Album>> getAlbums() async => [
    const Album(
      id: _albumId,
      title: 'FOCUS era',
      coverUrl: 'https://example.com/cover.jpg',
      year: 2025,
      photos: [
        Photo(id: 'p1', url: 'https://example.com/1.jpg', caption: 'Teaser'),
        Photo(id: 'p2', url: 'https://example.com/2.jpg'),
      ],
    ),
  ];
}

class _Votes implements VotingRepository {
  @override
  Future<List<VotingCampaign>> getCampaigns() async {
    final now = DateTime.now();
    return [
      VotingCampaign(
        id: 'sweep-open',
        title: 'Best Female Group of the Year',
        organizer: 'Example Music Awards',
        url: 'https://example.com/vote',
        closesAt: now.add(const Duration(days: 3)),
        note: 'One vote per account per day.',
      ),
      VotingCampaign(
        id: 'sweep-announced',
        title: 'Rookie of the Year',
        organizer: 'Example Awards',
        url: 'https://example.com/vote-2',
        opensAt: now.add(const Duration(days: 5)),
        closesAt: now.add(const Duration(days: 12)),
      ),
    ];
  }
}
