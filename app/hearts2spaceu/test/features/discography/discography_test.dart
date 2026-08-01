import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/app/theme/app_theme.dart';
import 'package:hearts2spaceu/app/widgets/states/empty_view.dart';
import 'package:hearts2spaceu/features/discography/data/asset_release_repository.dart';
import 'package:hearts2spaceu/features/discography/domain/newest_first.dart';
import 'package:hearts2spaceu/features/discography/domain/release.dart';
import 'package:hearts2spaceu/features/discography/domain/release_repository.dart';
import 'package:hearts2spaceu/features/discography/presentation/pages/discography_page.dart';
import 'package:hearts2spaceu/features/discography/presentation/providers/release_providers.dart';
import 'package:hearts2spaceu/features/discography/presentation/release_format.dart';

class _FakeReleaseRepository implements ReleaseRepository {
  _FakeReleaseRepository(this.releases);

  final List<Release> releases;

  @override
  Future<List<Release>> getReleases() async => releases;
}

Release _release(
  String id, {
  int year = 2025,
  String? type,
  DateTime? releaseDate,
  List<Track> tracks = const [],
}) => Release(
  id: id,
  title: id,
  year: year,
  type: type,
  releaseDate: releaseDate,
  tracks: tracks,
);

Widget _app(ReleaseRepository repository) => ProviderScope(
  overrides: [releaseRepositoryProvider.overrideWithValue(repository)],
  child: MaterialApp(theme: AppTheme.light, home: const DiscographyPage()),
);

void main() {
  group('newestFirst', () {
    test('orders by year, most recent first', () {
      final ordered = newestFirst([
        _release('old', year: 2025),
        _release('new', year: 2026),
      ]);

      expect(ordered.map((r) => r.id), ['new', 'old']);
    });

    test('an exact date outranks the year it sits in', () {
      // Two releases in the same year: the one with a curated date has to win,
      // otherwise a comeback ordered only by year falls back to the title.
      final ordered = newestFirst([
        _release('january', year: 2026, releaseDate: DateTime(2026, 1, 5)),
        _release('august', year: 2026, releaseDate: DateTime(2026, 8, 12)),
      ]);

      expect(ordered.map((r) => r.id), ['august', 'january']);
    });

    test('ties fall back to the title so the order is stable', () {
      final ordered = newestFirst([
        _release('zebra', year: 2026),
        _release('alpha', year: 2026),
      ]);

      expect(ordered.map((r) => r.id), ['alpha', 'zebra']);
    });

    test('does not mutate the input', () {
      final input = [_release('a', year: 2025), _release('b', year: 2026)];
      newestFirst(input);

      expect(input.map((r) => r.id), ['a', 'b']);
    });
  });

  group('parseReleases', () {
    test('reads a release with a track list', () {
      final releases = AssetReleaseRepository.parseReleases('''
        [
          {
            "id": "lemon-tang",
            "title": "Lemon Tang",
            "year": 2026,
            "type": "mini-album",
            "releaseDate": "2026-06-01",
            "note": "Second mini album",
            "coverUrl": "https://example.com/cover.jpg",
            "tracks": [
              {"title": "Lemon Tang", "isTitleTrack": true},
              {"title": "Second Song"}
            ]
          }
        ]
      ''');

      final release = releases.single;
      expect(release.id, 'lemon-tang');
      expect(release.type, Release.typeMiniAlbum);
      expect(release.releaseDate, DateTime(2026, 6, 1));
      expect(release.tracks.length, 2);
      expect(release.titleTrack?.title, 'Lemon Tang');
      // Absent means false, not null — the UI branches on it.
      expect(release.tracks.last.isTitleTrack, isFalse);
    });

    test('a release with no tracks parses to an empty list', () {
      // The shipped data is release-level only; this is the common case, not an
      // edge case.
      final releases = AssetReleaseRepository.parseReleases(
        '[{"id": "rude", "title": "RUDE!", "year": 2026}]',
      );

      expect(releases.single.tracks, isEmpty);
      expect(releases.single.titleTrack, isNull);
      expect(releases.single.coverUrl, isNull);
    });

    test('rejects a non-https cover url', () {
      expect(
        () => AssetReleaseRepository.parseReleases(
          '[{"id": "a", "title": "A", "year": 2026,'
          ' "coverUrl": "http://insecure.example.com/c.jpg"}]',
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects a payload that is not an array', () {
      expect(
        () => AssetReleaseRepository.parseReleases('{"releases": []}'),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('formatReleaseMeta', () {
    test('prints the format and the exact date when both are known', () {
      expect(
        formatReleaseMeta(
          _release(
            'x',
            year: 2026,
            type: Release.typeMiniAlbum,
            releaseDate: DateTime(2026, 6, 1),
          ),
        ),
        'Mini album · Jun 1, 2026',
      );
    });

    test('falls back to the year alone rather than inventing a day', () {
      expect(formatReleaseMeta(_release('x', year: 2025)), '2025');
    });

    test('omits an unrecorded format instead of guessing one', () {
      expect(
        formatReleaseMeta(
          _release('x', year: 2026, releaseDate: DateTime(2026, 8, 12)),
        ),
        'Aug 12, 2026',
      );
    });
  });

  group('DiscographyPage', () {
    testWidgets('lists the releases newest first', (tester) async {
      await tester.pumpWidget(
        _app(
          _FakeReleaseRepository([
            _release('The Chase', year: 2025),
            _release('RUDE!', year: 2026),
          ]),
        ),
      );
      await tester.pumpAndSettle();

      final newer = tester.getTopLeft(find.text('RUDE!')).dy;
      final older = tester.getTopLeft(find.text('The Chase')).dy;
      expect(newer, lessThan(older));
    });

    testWidgets('Empty — says nothing is recorded yet', (tester) async {
      await tester.pumpWidget(_app(_FakeReleaseRepository(const [])));
      await tester.pumpAndSettle();

      expect(find.byType(EmptyView), findsOneWidget);
      expect(find.text('No releases recorded yet.'), findsOneWidget);
    });
  });

  test('the shipped discography asset parses', () async {
    // Guards the curated file itself: a typo in discography.json would
    // otherwise only surface at runtime, on the user's device.
    TestWidgetsFlutterBinding.ensureInitialized();
    final releases = await const AssetReleaseRepository().getReleases();

    expect(releases, isNotEmpty);
    for (final release in releases) {
      expect(release.id, isNotEmpty, reason: 'every release needs an id');
      expect(release.title, isNotEmpty, reason: '${release.id} has no title');
    }
    // Ids must be unique — they are what the detail route looks up.
    final ids = releases.map((r) => r.id).toList();
    expect(ids.toSet().length, ids.length, reason: 'duplicate release id');
  });
}
