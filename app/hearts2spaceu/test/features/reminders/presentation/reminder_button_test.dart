import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/app/theme/app_theme.dart';
import 'package:hearts2spaceu/features/agenda/presentation/pages/agenda_page.dart';
import 'package:hearts2spaceu/features/collection/presentation/widgets/favorite_button.dart';
import 'package:hearts2spaceu/features/reminders/data/prefs_reminder_repository.dart';
import 'package:hearts2spaceu/features/reminders/domain/reminder.dart';
import 'package:hearts2spaceu/features/reminders/domain/reminder_scheduler.dart';
import 'package:hearts2spaceu/features/reminders/presentation/providers/reminder_providers.dart';
import 'package:hearts2spaceu/features/reminders/presentation/widgets/reminder_button.dart';
import 'package:hearts2spaceu/features/schedule/domain/event.dart';
import 'package:hearts2spaceu/features/schedule/domain/event_repository.dart';
import 'package:hearts2spaceu/features/schedule/presentation/providers/event_providers.dart';
import 'package:hearts2spaceu/features/voting/domain/voting_campaign.dart';
import 'package:hearts2spaceu/features/voting/domain/voting_repository.dart';
import 'package:hearts2spaceu/features/voting/presentation/providers/voting_providers.dart';
import 'package:hearts2spaceu/routes/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stands in for the platform, which `flutter test` does not have.
class _Scheduler implements ReminderScheduler {
  _Scheduler({this.grants = true, this.isSupported = true});

  final bool grants;
  @override
  final bool isSupported;

  int permissionRequests = 0;
  final scheduled = <String, Reminder>{};
  final cancelled = <String>[];

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return grants;
  }

  @override
  Future<void> schedule(Reminder reminder) async =>
      scheduled[reminder.key] = reminder;

  @override
  Future<void> cancel(String key) async {
    cancelled.add(key);
    scheduled.remove(key);
  }
}

class _Events implements EventRepository {
  _Events(this.events);

  final List<Event> events;

  @override
  Future<List<Event>> getEvents({bool forceRefresh = false}) async => events;
}

class _Votes implements VotingRepository {
  _Votes(this.campaigns, {this.fails = false});

  final List<VotingCampaign> campaigns;
  final bool fails;

  @override
  Future<List<VotingCampaign>> getCampaigns() async =>
      fails ? throw Exception('down') : campaigns;
}

Event _event(String id, Duration fromNow) =>
    Event(id: id, title: id, startDateTime: DateTime.now().add(fromNow));

VotingCampaign _vote(String id, Duration closesIn) => VotingCampaign(
  id: id,
  title: id,
  organizer: 'MAMA Awards',
  url: 'https://example.com/$id',
  closesAt: DateTime.now().add(closesIn),
);

const _days3 = Duration(days: 3, minutes: 5);

/// The Agenda as the app runs it: with reminders kept in step by the sync.
Widget _app(
  _Scheduler scheduler, {
  List<Event> events = const [],
  List<VotingCampaign> votes = const [],
  bool votesFail = false,
}) {
  return ProviderScope(
    overrides: [
      reminderSchedulerProvider.overrideWithValue(scheduler),
      eventRepositoryProvider.overrideWithValue(_Events(events)),
      votingRepositoryProvider.overrideWithValue(
        _Votes(votes, fails: votesFail),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      onGenerateRoute: AppRouter.onGenerateRoute,
      home: Consumer(
        builder: (context, ref, _) {
          ref.watch(reminderSyncProvider);
          return const AgendaPage();
        },
      ),
    ),
  );
}

Future<Map<String, DateTime>> _stored() =>
    const PrefsReminderRepository().load();

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('the bell turns a reminder on, and it survives a restart', (
    tester,
  ) async {
    final scheduler = _Scheduler();
    await tester.pumpWidget(
      _app(scheduler, events: [_event('Concert', _days3)]),
    );
    await tester.pumpAndSettle();

    // Nothing is asked before the reader wants anything.
    expect(scheduler.permissionRequests, 0);

    await tester.tap(find.byTooltip('Remind me'));
    await tester.pumpAndSettle();

    expect(scheduler.permissionRequests, 1);
    expect(scheduler.scheduled['event:Concert']!.body, 'Starts in 24 hours.');
    expect(find.textContaining('24 hours before it starts'), findsOneWidget);
    expect(find.byTooltip('Turn off reminder'), findsOneWidget);

    // A fresh app over the same storage: the bell is still lit.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      _app(_Scheduler(), events: [_event('Concert', _days3)]),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('Turn off reminder'), findsOneWidget);
    expect((await _stored()).keys, ['event:Concert']);
  });

  testWidgets('a refused permission leaves the bell dark and says why', (
    tester,
  ) async {
    // A bell lit without permission would be a lie: the reader would wait for
    // a notification that can never come.
    final scheduler = _Scheduler(grants: false);
    await tester.pumpWidget(
      _app(scheduler, events: [_event('Concert', _days3)]),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Remind me'));
    await tester.pumpAndSettle();

    expect(scheduler.scheduled, isEmpty);
    expect(find.byTooltip('Remind me'), findsOneWidget);
    expect(find.byTooltip('Turn off reminder'), findsNothing);
    expect(find.textContaining('Reminders need notifications'), findsOneWidget);
    expect(await _stored(), isEmpty);
  });

  testWidgets('turning it off cancels the scheduled notification', (
    tester,
  ) async {
    final scheduler = _Scheduler();
    await tester.pumpWidget(
      _app(scheduler, events: [_event('Concert', _days3)]),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Remind me'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Turn off reminder'));
    await tester.pumpAndSettle();

    expect(scheduler.cancelled, ['event:Concert']);
    expect(scheduler.scheduled, isEmpty);
    expect(find.byTooltip('Remind me'), findsOneWidget);
    expect(await _stored(), isEmpty);
  });

  testWidgets('a vote can be reminded too, in its own words', (tester) async {
    final scheduler = _Scheduler();
    await tester.pumpWidget(_app(scheduler, votes: [_vote('MAMA', _days3)]));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Remind me'));
    await tester.pumpAndSettle();

    expect(
      scheduler.scheduled['vote:MAMA']!.body,
      'Voting closes in 24 hours.',
    );
    expect(find.textContaining('24 hours before it closes'), findsOneWidget);
  });

  testWidgets('too close: the bell explains instead of pretending', (
    tester,
  ) async {
    final scheduler = _Scheduler();
    await tester.pumpWidget(
      _app(scheduler, votes: [_vote('MAMA', const Duration(minutes: 30))]),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Too close for a reminder'));
    await tester.pumpAndSettle();

    expect(scheduler.permissionRequests, 0);
    expect(scheduler.scheduled, isEmpty);
    expect(find.textContaining('too close'), findsOneWidget);
  });

  testWidgets('no bell where notifications cannot be scheduled', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(_Scheduler(isSupported: false), events: [_event('Concert', _days3)]),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FavoriteButton), findsOneWidget);
    expect(find.byTooltip('Remind me'), findsNothing);
  });

  testWidgets('both controls fit a 360dp row with a long title', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(360, 800)
      ..devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _app(
        _Scheduler(),
        events: [
          _event(
            'Hearts2Hearts 2026 World Tour Encore Concert in Seoul, Day Two',
            _days3,
          ),
        ],
        votes: [_vote('Best Female Group of the Year', _days3)],
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(ReminderButton), findsNWidgets(2));
    expect(find.byType(FavoriteButton), findsOneWidget);
  });

  group('kept in step with the data', () {
    late DateTime ahead;

    setUp(() async {
      ahead = DateTime.now().add(const Duration(days: 2));
      await const PrefsReminderRepository().save({
        'event:Concert': ahead,
        'vote:withdrawn': ahead,
      });
    });

    testWidgets('a vote gone after a successful load is cancelled', (
      tester,
    ) async {
      final scheduler = _Scheduler();
      await tester.pumpWidget(
        _app(scheduler, events: [_event('Concert', _days3)]),
      );
      await tester.pumpAndSettle();

      expect(scheduler.cancelled, ['vote:withdrawn']);
      expect((await _stored()).keys, ['event:Concert']);
      // Re-planning never asks for permission: that was given on the tap.
      expect(scheduler.permissionRequests, 0);
    });

    testWidgets('a vote list that failed to load cancels nothing', (
      tester,
    ) async {
      final scheduler = _Scheduler();
      await tester.pumpWidget(
        _app(scheduler, events: [_event('Concert', _days3)], votesFail: true),
      );
      await tester.pumpAndSettle();

      expect(scheduler.cancelled, isEmpty);
      expect(
        (await _stored()).keys,
        unorderedEquals(['event:Concert', 'vote:withdrawn']),
      );
    });
  });
}
