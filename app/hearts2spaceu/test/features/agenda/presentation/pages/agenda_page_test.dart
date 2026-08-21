import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/app/theme/app_theme.dart';
import 'package:hearts2spaceu/app/widgets/states/empty_view.dart';
import 'package:hearts2spaceu/app/widgets/states/error_view.dart';
import 'package:hearts2spaceu/app/widgets/states/loading_view.dart';
import 'package:hearts2spaceu/features/agenda/domain/agenda_item.dart';
import 'package:hearts2spaceu/features/agenda/presentation/pages/agenda_page.dart';
import 'package:hearts2spaceu/features/agenda/presentation/widgets/agenda_row.dart';
import 'package:hearts2spaceu/features/collection/domain/favorites_repository.dart';
import 'package:hearts2spaceu/features/collection/presentation/pages/collection_page.dart';
import 'package:hearts2spaceu/features/collection/presentation/providers/favorites_providers.dart';
import 'package:hearts2spaceu/features/schedule/domain/event.dart';
import 'package:hearts2spaceu/features/schedule/domain/event_repository.dart';
import 'package:hearts2spaceu/features/schedule/presentation/pages/event_detail_page.dart';
import 'package:hearts2spaceu/features/schedule/presentation/providers/event_providers.dart';
import 'package:hearts2spaceu/features/voting/data/http_voting_repository.dart';
import 'package:hearts2spaceu/features/voting/domain/voting_campaign.dart';
import 'package:hearts2spaceu/features/voting/domain/voting_repository.dart';
import 'package:hearts2spaceu/features/voting/presentation/providers/voting_providers.dart';
import 'package:hearts2spaceu/routes/app_router.dart';
import 'package:hearts2spaceu/shared/services/url_opener.dart';

class _FakeEventRepository implements EventRepository {
  _FakeEventRepository(this.events);

  final List<Event> events;

  @override
  Future<List<Event>> getEvents() async => events;
}

class _ThrowingEventRepository implements EventRepository {
  @override
  Future<List<Event>> getEvents() async => throw Exception('boom');
}

class _DelayedEventRepository implements EventRepository {
  @override
  Future<List<Event>> getEvents() =>
      Future.delayed(const Duration(seconds: 1), () => const <Event>[]);
}

class _FakeVotingRepository implements VotingRepository {
  _FakeVotingRepository(this.campaigns);

  final List<VotingCampaign> campaigns;

  @override
  Future<List<VotingCampaign>> getCampaigns() async => campaigns;
}

class _ThrowingVotingRepository implements VotingRepository {
  @override
  Future<List<VotingCampaign>> getCampaigns() async => throw Exception('down');
}

/// Fails the way a broken `voting.json` really fails — by parsing it.
class _MalformedVotingRepository implements VotingRepository {
  @override
  Future<List<VotingCampaign>> getCampaigns() async =>
      HttpVotingRepository.parseCampaigns('{"not":"an array"}');
}

/// Fails the first call, then succeeds — to exercise the notice's Retry.
class _FlakyVotingRepository implements VotingRepository {
  _FlakyVotingRepository(this.campaigns);

  final List<VotingCampaign> campaigns;
  bool _firstAttempt = true;

  @override
  Future<List<VotingCampaign>> getCampaigns() async {
    if (_firstAttempt) {
      _firstAttempt = false;
      throw Exception('down');
    }
    return campaigns;
  }
}

class _InMemoryFavorites implements FavoritesRepository {
  Set<String> saved = {};

  @override
  Future<Set<String>> load() async => saved;

  @override
  Future<void> save(Set<String> keys) async => saved = {...keys};
}

class _RecordingUrlOpener implements UrlOpener {
  final opened = <String>[];

  @override
  Future<bool> open(String url) async {
    opened.add(url);
    return true;
  }
}

class _FailingUrlOpener implements UrlOpener {
  @override
  Future<bool> open(String url) async => false;
}

Widget _app({
  EventRepository? events,
  VotingRepository? votes,
  UrlOpener? urlOpener,
  FavoritesRepository? favorites,
  Widget home = const AgendaPage(),
}) {
  return ProviderScope(
    overrides: [
      eventRepositoryProvider.overrideWithValue(
        events ?? _FakeEventRepository(const []),
      ),
      votingRepositoryProvider.overrideWithValue(
        votes ?? _FakeVotingRepository(const []),
      ),
      favoritesRepositoryProvider.overrideWithValue(
        favorites ?? _InMemoryFavorites(),
      ),
      if (urlOpener != null) urlOpenerProvider.overrideWithValue(urlOpener),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      onGenerateRoute: AppRouter.onGenerateRoute,
      home: home,
    ),
  );
}

/// A few minutes past the whole day, so the countdown reads the round number a
/// reader would expect rather than one day less.
Duration _inDays(int days) => Duration(days: days, minutes: 5);

Event _event(
  String id, {
  Duration? fromNow,
  DateTime? at,
  bool allDay = false,
  String? location,
}) => Event(
  id: id,
  title: id,
  startDateTime: at ?? DateTime.now().add(fromNow!),
  allDay: allDay,
  location: location,
);

VotingCampaign _vote(
  String id, {
  required Duration closesIn,
  Duration? opensIn,
}) => VotingCampaign(
  id: id,
  title: id,
  organizer: 'MAMA Awards',
  url: 'https://example.com/$id',
  closesAt: DateTime.now().add(closesIn),
  opensAt: opensIn == null ? null : DateTime.now().add(opensIn),
);

void main() {
  group('agendaDueLabel', () {
    final now = DateTime(2026, 8, 20, 12);

    test('an event says when it starts', () {
      final event = AgendaItem(
        kind: AgendaKind.event,
        id: 'e1',
        title: 'Concert',
        dueAt: now.add(const Duration(days: 3)),
      );

      expect(agendaDueLabel(event, now), 'in 3 days');
    });

    test('a vote says when it closes, never just "in"', () {
      // "in 3 days" on a vote reads as "voting opens in 3 days" — the exact
      // opposite of what the date means.
      final vote = AgendaItem(
        kind: AgendaKind.vote,
        id: 'v1',
        title: 'Best Female Group',
        dueAt: now.add(const Duration(days: 3)),
      );

      expect(agendaDueLabel(vote, now), 'Closes in 3 days');
    });

    test('an upcoming vote still counts down to its close', () {
      final vote = AgendaItem(
        kind: AgendaKind.vote,
        id: 'v1',
        title: 'Best Female Group',
        dueAt: now.add(const Duration(days: 10)),
        isUpcomingVote: true,
      );

      expect(agendaDueLabel(vote, now), 'Closes in 10 days');
    });
  });

  group('AgendaPage states', () {
    testWidgets('Loading — while the events are still being read', (
      tester,
    ) async {
      await tester.pumpWidget(_app(events: _DelayedEventRepository()));
      await tester.pump();

      expect(find.byType(LoadingView), findsOneWidget);

      // Let the pending load finish, or the binding reports a stray timer.
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
    });

    testWidgets('Empty — says nothing is scheduled, not that it broke', (
      tester,
    ) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      expect(find.byType(EmptyView), findsOneWidget);
      expect(find.textContaining('Nothing scheduled yet'), findsOneWidget);
      expect(find.byType(ErrorView), findsNothing);
      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('Error — bundled events failing takes the page down', (
      tester,
    ) async {
      await tester.pumpWidget(_app(events: _ThrowingEventRepository()));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorView), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byType(AgendaRow), findsNothing);
    });

    testWidgets('Data — both sources in one list, soonest deadline first', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          events: _FakeEventRepository([
            _event('Alpha Show', fromNow: _inDays(3)),
          ]),
          votes: _FakeVotingRepository([
            _vote('Best Group', closesIn: _inDays(1)),
          ]),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AgendaRow), findsNWidgets(2));

      final rows = tester.widgetList<AgendaRow>(find.byType(AgendaRow));
      expect(rows.map((r) => r.item.title), ['Best Group', 'Alpha Show']);
    });
  });

  group('AgendaPage content', () {
    testWidgets('each kind gets the verb its date actually means', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          events: _FakeEventRepository([
            _event('Alpha Show', fromNow: _inDays(3)),
          ]),
          votes: _FakeVotingRepository([
            _vote('Best Group', closesIn: _inDays(3)),
          ]),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Closes in 3 days'), findsOneWidget);
      expect(find.text('in 3 days'), findsOneWidget);
    });

    testWidgets('groups by how close the deadline is, with no empty headers', (
      tester,
    ) async {
      final today = DateTime.now();

      await tester.pumpWidget(
        _app(
          events: _FakeEventRepository([
            _event(
              'Today Show',
              at: DateTime(today.year, today.month, today.day),
              allDay: true,
            ),
            _event('Far Off Show', fromNow: _inDays(30)),
          ]),
          votes: _FakeVotingRepository([
            _vote('Best Group', closesIn: _inDays(2)),
          ]),
        ),
      );
      await tester.pumpAndSettle();

      // SectionHeader renders its label uppercased.
      expect(find.text('TODAY'), findsOneWidget);
      expect(find.text('THIS WEEK'), findsOneWidget);
      expect(find.text('LATER'), findsOneWidget);
    });

    testWidgets('an all-day event shows its date and no invented time', (
      tester,
    ) async {
      final today = DateTime.now();

      await tester.pumpWidget(
        _app(
          events: _FakeEventRepository([
            _event(
              'Comeback Day',
              at: DateTime(today.year, today.month, today.day),
              allDay: true,
            ),
          ]),
        ),
      );
      await tester.pumpAndSettle();

      final date =
          '${today.day.toString().padLeft(2, '0')}/'
          '${today.month.toString().padLeft(2, '0')}/${today.year}';

      expect(find.text(date), findsOneWidget);
      expect(find.textContaining('00:00'), findsNothing);
    });

    testWidgets('a vote that has not opened is marked, not left to look live', (
      tester,
    ) async {
      final opener = _RecordingUrlOpener();

      await tester.pumpWidget(
        _app(
          votes: _FakeVotingRepository([
            _vote('Not Yet', closesIn: _inDays(10), opensIn: _inDays(2)),
          ]),
          urlOpener: opener,
        ),
      );
      await tester.pumpAndSettle();

      // TypeBadge renders both labels uppercased.
      expect(find.text('VOTE'), findsOneWidget);
      expect(find.text('UPCOMING'), findsOneWidget);

      await tester.tap(find.text('Not Yet'));
      await tester.pumpAndSettle();

      // Tapping a vote that has not opened must lead nowhere, exactly as in
      // the Voting Hub.
      expect(opener.opened, isEmpty);
    });

    testWidgets('does not overflow at 360dp with a long event title', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(360, 800)
        ..devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _app(
          events: _FakeEventRepository([
            _event(
              'Hearts2Hearts 2026 World Tour Encore Concert in Seoul, Day Two',
              fromNow: _inDays(2),
              location: 'KSPO Dome, Olympic Park, Seoul, South Korea',
            ),
          ]),
          votes: _FakeVotingRepository([
            _vote('Best Female Group of the Year', closesIn: _inDays(1)),
          ]),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('AgendaPage taps', () {
    testWidgets('an event row opens the event detail page', (tester) async {
      await tester.pumpWidget(
        _app(
          events: _FakeEventRepository([
            _event('Alpha Show', fromNow: _inDays(2)),
          ]),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Alpha Show'));
      await tester.pumpAndSettle();

      expect(find.byType(EventDetailPage), findsOneWidget);
    });

    testWidgets('a vote row opens the official link', (tester) async {
      final opener = _RecordingUrlOpener();

      await tester.pumpWidget(
        _app(
          votes: _FakeVotingRepository([
            _vote('Best Group', closesIn: _inDays(2)),
          ]),
          urlOpener: opener,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Best Group'));
      await tester.pumpAndSettle();

      expect(opener.opened, ['https://example.com/Best Group']);
    });

    testWidgets(
      'a link that will not open says so instead of failing quietly',
      (tester) async {
        await tester.pumpWidget(
          _app(
            votes: _FakeVotingRepository([
              _vote('Best Group', closesIn: _inDays(2)),
            ]),
            urlOpener: _FailingUrlOpener(),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Best Group'));
        await tester.pumpAndSettle();

        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.textContaining("Couldn't open"), findsOneWidget);
      },
    );

    testWidgets('saving an event from the Agenda shows up in the Collection', (
      tester,
    ) async {
      final favorites = _InMemoryFavorites();

      await tester.pumpWidget(
        _app(
          events: _FakeEventRepository([
            _event('Alpha Show', fromNow: _inDays(2)),
          ]),
          favorites: favorites,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.favorite_border_rounded));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
      expect(favorites.saved, {'event:Alpha Show'});

      // The same store, read by the page that promises to keep it.
      final context = tester.element(find.byType(AgendaPage));
      Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const CollectionPage()));
      await tester.pumpAndSettle();

      expect(find.byType(CollectionPage), findsOneWidget);
      expect(find.text('Alpha Show'), findsOneWidget);
    });
  });

  group('AgendaPage partial failure', () {
    testWidgets('votes failing leaves the events standing and says so', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          events: _FakeEventRepository([
            _event('Alpha Show', fromNow: _inDays(2)),
          ]),
          votes: _ThrowingVotingRepository(),
        ),
      );
      await tester.pumpAndSettle();

      // The page does not fall over…
      expect(find.byType(AgendaRow), findsOneWidget);
      expect(find.text('Alpha Show'), findsOneWidget);
      // …and the missing half is not swallowed either.
      expect(find.textContaining('Check your connection'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('broken voting data does not blame the connection', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          events: _FakeEventRepository([
            _event('Alpha Show', fromNow: _inDays(2)),
          ]),
          votes: _MalformedVotingRepository(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('on our side'), findsOneWidget);
      expect(find.textContaining('Check your connection'), findsNothing);
    });

    testWidgets('Retry brings the missing votes back', (tester) async {
      await tester.pumpWidget(
        _app(
          events: _FakeEventRepository([
            _event('Alpha Show', fromNow: _inDays(3)),
          ]),
          votes: _FlakyVotingRepository([
            _vote('Best Group', closesIn: _inDays(1)),
          ]),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Best Group'), findsNothing);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.text('Best Group'), findsOneWidget);
      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('with no events either, it still explains both halves', (
      tester,
    ) async {
      await tester.pumpWidget(_app(votes: _ThrowingVotingRepository()));
      await tester.pumpAndSettle();

      expect(find.textContaining('Check your connection'), findsOneWidget);
      expect(find.byType(EmptyView), findsOneWidget);
    });
  });
}
