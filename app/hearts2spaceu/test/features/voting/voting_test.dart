import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/app/widgets/states/empty_view.dart';
import 'package:hearts2spaceu/app/widgets/states/error_view.dart';
import 'package:hearts2spaceu/features/voting/data/http_voting_repository.dart';
import 'package:hearts2spaceu/features/voting/domain/open_votes.dart';
import 'package:hearts2spaceu/features/voting/domain/voting_campaign.dart';
import 'package:hearts2spaceu/features/voting/domain/voting_repository.dart';
import 'package:hearts2spaceu/features/voting/presentation/pages/voting_hub_page.dart';
import 'package:hearts2spaceu/features/voting/presentation/providers/voting_providers.dart';
import 'package:hearts2spaceu/features/voting/presentation/widgets/voting_card.dart';
import 'package:hearts2spaceu/shared/services/url_opener.dart';

VotingCampaign _campaign(
  String id,
  DateTime closesAt, {
  DateTime? opensAt,
  String? note,
}) => VotingCampaign(
  id: id,
  title: id,
  organizer: 'Awards',
  url: 'https://example.com/$id',
  closesAt: closesAt,
  opensAt: opensAt,
  note: note,
);

/// Runs [body] and hands back whatever it threw, so a test can assert on the
/// real failure the parser produces instead of a hand-built stand-in.
Object _thrownBy(void Function() body) {
  try {
    body();
  } catch (error) {
    return error;
  }
  fail('Expected $body to throw.');
}

class _FakeRepository implements VotingRepository {
  _FakeRepository(this.campaigns);

  final List<VotingCampaign> campaigns;

  @override
  Future<List<VotingCampaign>> getCampaigns() async => campaigns;
}

class _ThrowingRepository implements VotingRepository {
  @override
  Future<List<VotingCampaign>> getCampaigns() async => throw Exception('down');
}

/// Fails the way a broken `voting.json` really fails — by parsing it.
class _MalformedRepository implements VotingRepository {
  @override
  Future<List<VotingCampaign>> getCampaigns() async =>
      HttpVotingRepository.parseCampaigns('{"not":"an array"}');
}

class _RecordingUrlOpener implements UrlOpener {
  final opened = <String>[];

  @override
  Future<bool> open(String url) async {
    opened.add(url);
    return true;
  }
}

Widget _app(VotingRepository repository, {UrlOpener? urlOpener}) {
  return ProviderScope(
    overrides: [
      votingRepositoryProvider.overrideWithValue(repository),
      if (urlOpener != null) urlOpenerProvider.overrideWithValue(urlOpener),
    ],
    child: const MaterialApp(home: VotingHubPage()),
  );
}

void main() {
  final now = DateTime(2026, 11, 1, 12);

  group('openAndUpcoming', () {
    test('drops votes that already closed', () {
      final closed = _campaign('closed', now.subtract(const Duration(days: 1)));
      final open = _campaign('open', now.add(const Duration(days: 1)));

      expect(openAndUpcoming([closed, open], now).map((c) => c.id), ['open']);
    });

    test('keeps a vote closing exactly now', () {
      final edge = _campaign('edge', now);
      expect(openAndUpcoming([edge], now), [edge]);
    });

    test('drops a vote one minute after it closed', () {
      // Unlike the schedule, voting really is over the instant it closes.
      final justClosed = _campaign(
        'just-closed',
        now.subtract(const Duration(minutes: 1)),
      );
      expect(openAndUpcoming([justClosed], now), isEmpty);
    });

    test('sorts by soonest deadline first', () {
      final later = _campaign('later', now.add(const Duration(days: 5)));
      final soon = _campaign('soon', now.add(const Duration(days: 1)));

      expect(openAndUpcoming([later, soon], now).map((c) => c.id), [
        'soon',
        'later',
      ]);
    });

    test('keeps source order for identical deadlines', () {
      final at = now.add(const Duration(days: 2));
      final first = _campaign('first', at);
      final second = _campaign('second', at);

      expect(openAndUpcoming([first, second], now).map((c) => c.id), [
        'first',
        'second',
      ]);
    });

    test('does not mutate the input list', () {
      final campaigns = [
        _campaign('b', now.add(const Duration(days: 2))),
        _campaign('a', now.add(const Duration(days: 1))),
      ];
      final snapshot = List.of(campaigns);

      openAndUpcoming(campaigns, now);

      expect(campaigns, snapshot);
    });
  });

  group('isUpcomingAt', () {
    test('is upcoming before it opens', () {
      final c = _campaign(
        'c',
        now.add(const Duration(days: 10)),
        opensAt: now.add(const Duration(days: 2)),
      );
      expect(c.isUpcomingAt(now), isTrue);
    });

    test('is open once opensAt has passed', () {
      final c = _campaign(
        'c',
        now.add(const Duration(days: 10)),
        opensAt: now.subtract(const Duration(days: 1)),
      );
      expect(c.isUpcomingAt(now), isFalse);
    });

    test('is open when no opensAt is given', () {
      expect(
        _campaign('c', now.add(const Duration(days: 1))).isUpcomingAt(now),
        isFalse,
      );
    });
  });

  group('parseCampaigns', () {
    test('parses a full campaign', () {
      const raw = '''
      [{
        "id": "mama", "title": "Best Female Group", "organizer": "MAMA Awards",
        "url": "https://example.com/vote",
        "opensAt": "2026-10-01T00:00:00Z", "closesAt": "2026-11-20T15:00:00Z",
        "note": "Daily voting"
      }]
      ''';

      final c = HttpVotingRepository.parseCampaigns(raw).single;

      expect(c.id, 'mama');
      expect(c.organizer, 'MAMA Awards');
      expect(c.closesAt, DateTime.utc(2026, 11, 20, 15));
      expect(c.opensAt, DateTime.utc(2026, 10, 1));
      expect(c.note, 'Daily voting');
    });

    test('rejects a non-https url', () {
      const raw =
          '[{"id":"a","title":"T","organizer":"O","url":"http://e.com","closesAt":"2026-11-20T15:00:00Z"}]';

      expect(
        () => HttpVotingRepository.parseCampaigns(raw),
        throwsFormatException,
      );
    });

    test('rejects a campaign with no closesAt', () {
      // Without a deadline an expired vote could never be hidden.
      const raw =
          '[{"id":"a","title":"T","organizer":"O","url":"https://e.com"}]';

      expect(
        () => HttpVotingRepository.parseCampaigns(raw),
        throwsA(isA<TypeError>()),
      );
    });

    test('returns empty for an empty array', () {
      expect(HttpVotingRepository.parseCampaigns('[]'), isEmpty);
    });
  });

  group('formatRemaining', () {
    test('describes days, hours, and minutes', () {
      expect(formatRemaining(const Duration(days: 3)), 'in 3 days');
      expect(formatRemaining(const Duration(days: 1)), 'in 1 day');
      expect(formatRemaining(const Duration(hours: 5)), 'in 5 hours');
      expect(formatRemaining(const Duration(minutes: 30)), 'in 30 min');
      expect(formatRemaining(const Duration(seconds: 20)), 'very soon');
    });
  });

  group('votingErrorMessage', () {
    test('blames the connection when the network failed', () {
      expect(
        votingErrorMessage(Exception('down')),
        contains('Check your connection'),
      );
    });

    test('blames our data when the list is not an array', () {
      // The reader cannot fix our JSON, so we must not send them to their WiFi.
      final message = votingErrorMessage(
        _thrownBy(() => HttpVotingRepository.parseCampaigns('{"a":1}')),
      );

      expect(message, contains('on our side'));
      expect(message, isNot(contains('Check your connection')));
    });

    test('blames our data when a required field is missing', () {
      // A missing `closesAt` surfaces as a TypeError, not a FormatException —
      // both are still our mistake, not the reader's.
      final message = votingErrorMessage(
        _thrownBy(
          () => HttpVotingRepository.parseCampaigns(
            '[{"id":"a","title":"T","organizer":"O","url":"https://e.com"}]',
          ),
        ),
      );

      expect(message, contains('on our side'));
    });

    test('blames our data when a url is not https', () {
      final message = votingErrorMessage(
        _thrownBy(
          () => HttpVotingRepository.parseCampaigns(
            '[{"id":"a","title":"T","organizer":"O","url":"http://e.com",'
            '"closesAt":"2026-11-20T15:00:00Z"}]',
          ),
        ),
      );

      expect(message, contains('on our side'));
    });
  });

  group('VotingCard', () {
    Widget card(VotingCampaign campaign) => MaterialApp(
      home: Scaffold(
        body: VotingCard(campaign: campaign, now: now),
      ),
    );

    testWidgets('shows the curated note', (tester) async {
      await tester.pumpWidget(
        card(
          _campaign(
            'c',
            now.add(const Duration(days: 3)),
            note: 'Daily voting',
          ),
        ),
      );

      expect(find.text('Daily voting'), findsOneWidget);
    });

    testWidgets('leaves out the note line when there is none', (tester) async {
      await tester.pumpWidget(card(_campaign('c', now.add(Duration(days: 3)))));

      // Title and the organiser/deadline line, and nothing blank after them.
      expect(find.byType(Text), findsNWidgets(2));
    });

    testWidgets('leaves out an empty note rather than an empty line', (
      tester,
    ) async {
      await tester.pumpWidget(
        card(_campaign('c', now.add(const Duration(days: 3)), note: '')),
      );

      expect(find.byType(Text), findsNWidgets(2));
    });
  });

  group('VotingHubPage', () {
    testWidgets('Empty — explains that off-season is normal', (tester) async {
      await tester.pumpWidget(_app(_FakeRepository(const [])));
      await tester.pumpAndSettle();

      expect(find.byType(EmptyView), findsOneWidget);
      expect(find.textContaining('No votes running'), findsOneWidget);
    });

    testWidgets('Error — a network failure points at the connection', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_ThrowingRepository()));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorView), findsOneWidget);
      expect(find.textContaining('Check your connection'), findsOneWidget);
    });

    testWidgets('Error — broken data does not blame the connection', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_MalformedRepository()));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorView), findsOneWidget);
      expect(find.textContaining('on our side'), findsOneWidget);
      expect(find.textContaining('Check your connection'), findsNothing);
    });

    testWidgets('Empty is not the error state', (tester) async {
      // The two must never be confusable: off-season shows no error styling
      // and no Retry, a failure shows both.
      await tester.pumpWidget(_app(_FakeRepository(const [])));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorView), findsNothing);
      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('Data — shows open votes and opens the link on tap', (
      tester,
    ) async {
      final opener = _RecordingUrlOpener();
      final open = _campaign(
        'open-vote',
        DateTime.now().add(const Duration(days: 3)),
      );
      await tester.pumpWidget(_app(_FakeRepository([open]), urlOpener: opener));
      await tester.pumpAndSettle();

      expect(find.byType(VotingCard), findsOneWidget);

      await tester.tap(find.text('open-vote'));
      await tester.pumpAndSettle();

      expect(opener.opened, ['https://example.com/open-vote']);
    });

    testWidgets('an upcoming vote is shown but not tappable', (tester) async {
      final opener = _RecordingUrlOpener();
      final upcoming = _campaign(
        'not-yet',
        DateTime.now().add(const Duration(days: 10)),
        opensAt: DateTime.now().add(const Duration(days: 2)),
      );
      await tester.pumpWidget(
        _app(_FakeRepository([upcoming]), urlOpener: opener),
      );
      await tester.pumpAndSettle();

      // TypeBadge renders the status uppercased.
      expect(find.text('UPCOMING'), findsOneWidget);

      await tester.tap(find.text('not-yet'));
      await tester.pumpAndSettle();

      // Tapping a vote that has not opened must lead nowhere.
      expect(opener.opened, isEmpty);
    });
  });
}
