import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/features/agenda/domain/agenda_item.dart';
import 'package:hearts2spaceu/features/agenda/domain/build_agenda.dart';
import 'package:hearts2spaceu/features/schedule/domain/event.dart';
import 'package:hearts2spaceu/features/voting/domain/voting_campaign.dart';

Event _event(
  String id,
  DateTime startDateTime, {
  bool allDay = false,
  String? location,
}) => Event(
  id: id,
  title: id,
  startDateTime: startDateTime,
  allDay: allDay,
  location: location,
);

VotingCampaign _vote(String id, DateTime closesAt, {DateTime? opensAt}) =>
    VotingCampaign(
      id: id,
      title: id,
      organizer: 'Awards',
      url: 'https://example.com/$id',
      closesAt: closesAt,
      opensAt: opensAt,
    );

AgendaItem _item(String id, DateTime dueAt, {AgendaKind? kind}) =>
    AgendaItem(kind: kind ?? AgendaKind.event, id: id, title: id, dueAt: dueAt);

void main() {
  final now = DateTime(2026, 8, 20, 12);

  group('buildAgenda', () {
    test('returns nothing when both sources are empty', () {
      expect(buildAgenda(events: const [], votes: const [], now: now), isEmpty);
    });

    test('merges both sources onto one timeline, soonest first', () {
      final items = buildAgenda(
        events: [
          _event('event-in-2', now.add(const Duration(days: 2))),
          _event('event-in-6', now.add(const Duration(days: 6))),
        ],
        votes: [
          _vote('vote-in-4', now.add(const Duration(days: 4))),
          _vote('vote-in-1', now.add(const Duration(days: 1))),
        ],
        now: now,
      );

      expect(items.map((i) => i.id), [
        'vote-in-1',
        'event-in-2',
        'vote-in-4',
        'event-in-6',
      ]);
    });

    test('puts the vote first when a vote and an event share an instant', () {
      // A vote expires; a missed event can still be caught up on.
      final at = now.add(const Duration(days: 3));

      final items = buildAgenda(
        events: [_event('event', at)],
        votes: [_vote('vote', at)],
        now: now,
      );

      expect(items.map((i) => i.id), ['vote', 'event']);
    });

    test('keeps each source order for items of the same kind', () {
      final at = now.add(const Duration(days: 3));

      final items = buildAgenda(
        events: [_event('event-a', at), _event('event-b', at)],
        votes: [_vote('vote-a', at), _vote('vote-b', at)],
        now: now,
      );

      expect(items.map((i) => i.id), [
        'vote-a',
        'vote-b',
        'event-a',
        'event-b',
      ]);
    });

    test('an item due exactly now still sorts ahead of a later one', () {
      final items = buildAgenda(
        events: [_event('later', now.add(const Duration(minutes: 1)))],
        votes: [_vote('right-now', now)],
        now: now,
      );

      expect(items.map((i) => i.id), ['right-now', 'later']);
    });

    test('does not filter what the owning features already filtered', () {
      // `upcomingSorted` drops past events and `openAndUpcoming` drops closed
      // votes. Judging that a second time here would create a second place to
      // change whenever either rule moves.
      final items = buildAgenda(
        events: [_event('past', now.subtract(const Duration(days: 2)))],
        votes: [_vote('closed', now.subtract(const Duration(days: 1)))],
        now: now,
      );

      expect(items.map((i) => i.id), ['past', 'closed']);
    });

    test('carries an event across as an event row', () {
      final start = now.add(const Duration(days: 1));

      final item = buildAgenda(
        events: [_event('e1', start, allDay: true, location: 'Seoul')],
        votes: const [],
        now: now,
      ).single;

      expect(item.kind, AgendaKind.event);
      expect(item.id, 'e1');
      expect(item.dueAt, start);
      expect(item.subtitle, 'Seoul');
      expect(item.isAllDay, isTrue);
      // Events are opened in the app, not linked out to.
      expect(item.url, isNull);
    });

    test('carries a vote across as a vote row, keyed on when it closes', () {
      final closes = now.add(const Duration(days: 5));

      final item = buildAgenda(
        events: const [],
        votes: [_vote('v1', closes)],
        now: now,
      ).single;

      expect(item.kind, AgendaKind.vote);
      expect(item.dueAt, closes);
      expect(item.subtitle, 'Awards');
      expect(item.url, 'https://example.com/v1');
      expect(item.isUpcomingVote, isFalse);
      expect(item.isAllDay, isFalse);
    });

    test('marks a vote that has not opened yet', () {
      final item = buildAgenda(
        events: const [],
        votes: [
          _vote(
            'v1',
            now.add(const Duration(days: 10)),
            opensAt: now.add(const Duration(days: 2)),
          ),
        ],
        now: now,
      ).single;

      expect(item.isUpcomingVote, isTrue);
      // It is still sorted by its deadline, not by when it opens.
      expect(item.dueAt, now.add(const Duration(days: 10)));
    });

    test('does not mutate either input list', () {
      final events = [
        _event('b', now.add(const Duration(days: 2))),
        _event('a', now.add(const Duration(days: 1))),
      ];
      final votes = [_vote('v', now.add(const Duration(days: 3)))];
      final eventsBefore = List.of(events);
      final votesBefore = List.of(votes);

      buildAgenda(events: events, votes: votes, now: now);

      expect(events, eventsBefore);
      expect(votes, votesBefore);
    });
  });

  group('groupByProximity', () {
    test('returns nothing for an empty agenda', () {
      expect(groupByProximity(const [], now), isEmpty);
    });

    test('groups anything on today\'s date as Today', () {
      final groups = groupByProximity([
        _item('this-morning', DateTime(2026, 8, 20, 9)),
        _item('tonight', DateTime(2026, 8, 20, 23, 59)),
      ], now);

      expect(groups.single.proximity, AgendaProximity.today);
      expect(groups.single.items.map((i) => i.id), ['this-morning', 'tonight']);
    });

    test('midnight tomorrow is no longer Today', () {
      final groups = groupByProximity([
        _item('tomorrow', DateTime(2026, 8, 21)),
      ], now);

      expect(groups.single.proximity, AgendaProximity.thisWeek);
    });

    test('the seventh day is still This week', () {
      final groups = groupByProximity([
        _item('day-7', now.add(const Duration(days: 7))),
      ], now);

      expect(groups.single.proximity, AgendaProximity.thisWeek);
    });

    test('a minute past the seventh day is Later', () {
      final groups = groupByProximity([
        _item('just-past', now.add(const Duration(days: 7, minutes: 1))),
      ], now);

      expect(groups.single.proximity, AgendaProximity.later);
    });

    test('leaves out an empty bucket entirely', () {
      // No header for a group with nothing under it.
      final groups = groupByProximity([
        _item('today', DateTime(2026, 8, 20, 18)),
        _item('far-off', now.add(const Duration(days: 40))),
      ], now);

      expect(groups.map((g) => g.proximity), [
        AgendaProximity.today,
        AgendaProximity.later,
      ]);
    });

    test('returns the buckets nearest first', () {
      final groups = groupByProximity([
        _item('today', DateTime(2026, 8, 20, 18)),
        _item('in-3-days', now.add(const Duration(days: 3))),
        _item('in-30-days', now.add(const Duration(days: 30))),
      ], now);

      expect(groups.map((g) => g.proximity), [
        AgendaProximity.today,
        AgendaProximity.thisWeek,
        AgendaProximity.later,
      ]);
    });

    test('keeps the order it was given inside a bucket', () {
      final items = [
        _item('vote', now.add(const Duration(days: 3)), kind: AgendaKind.vote),
        _item('event', now.add(const Duration(days: 4))),
      ];

      expect(groupByProximity(items, now).single.items.map((i) => i.id), [
        'vote',
        'event',
      ]);
    });

    test('does not mutate the input list', () {
      final items = [
        _item('today', DateTime(2026, 8, 20, 18)),
        _item('later', now.add(const Duration(days: 30))),
      ];
      final before = List.of(items);

      groupByProximity(items, now);

      expect(items, before);
    });
  });
}
