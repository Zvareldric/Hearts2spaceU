import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/features/agenda/domain/agenda_item.dart';
import 'package:hearts2spaceu/features/reminders/domain/plan_reminders.dart';

final _now = DateTime(2026, 10, 20, 12);

AgendaItem _vote(String id, DateTime closesAt) => AgendaItem(
  kind: AgendaKind.vote,
  id: id,
  title: 'Vote $id',
  dueAt: closesAt,
);

AgendaItem _event(String id, DateTime startsAt, {bool allDay = false}) =>
    AgendaItem(
      kind: AgendaKind.event,
      id: id,
      title: 'Event $id',
      dueAt: startsAt,
      isAllDay: allDay,
    );

void main() {
  group('reminderFireTime', () {
    test('a day before, while that is still ahead', () {
      final due = _now.add(const Duration(days: 3));
      expect(
        reminderFireTime(_vote('v', due), _now),
        due.subtract(const Duration(hours: 24)),
      );
    });

    test('an hour before, once a day before has passed', () {
      // The fan who finds a vote 20 hours before it closes is the one who most
      // needs reminding; a single fixed lead would refuse them.
      final due = _now.add(const Duration(hours: 20));
      expect(
        reminderFireTime(_vote('v', due), _now),
        due.subtract(const Duration(hours: 1)),
      );
    });

    test('nothing once both have passed', () {
      final due = _now.add(const Duration(minutes: 50));
      expect(reminderFireTime(_vote('v', due), _now), isNull);
    });

    test('exactly 24 hours out is too late for the day-before tier', () {
      // A reminder due this very instant is not "ahead", so it drops a tier
      // rather than being scheduled for a moment that has already gone.
      final due = _now.add(const Duration(hours: 24));
      expect(
        reminderFireTime(_vote('v', due), _now),
        due.subtract(const Duration(hours: 1)),
      );
    });

    test('exactly one hour out is too late for any reminder', () {
      final due = _now.add(const Duration(hours: 1));
      expect(reminderFireTime(_vote('v', due), _now), isNull);
    });

    test('an all-day event fires at 09:00 the day before, not midnight', () {
      final day = DateTime(2026, 10, 25);
      expect(
        reminderFireTime(_event('e', day, allDay: true), _now),
        DateTime(2026, 10, 24, 9),
      );
    });

    test('an all-day event whose morning-before has passed gets nothing', () {
      final day = DateTime(2026, 10, 21);
      final lateMorning = DateTime(2026, 10, 20, 9, 1);
      expect(
        reminderFireTime(_event('e', day, allDay: true), lateMorning),
        isNull,
      );
    });

    test('an event in another zone fires a day before its real instant', () {
      // 20:00 KST is 11:00 UTC. Reading the printed 20:00 on the reader's own
      // clock would ring two hours late in Jakarta.
      final event = AgendaItem(
        kind: AgendaKind.event,
        id: 'e',
        title: 'Concert',
        dueAt: DateTime(2026, 10, 25, 20),
        zoneLabel: 'KST',
        zoneOffset: const Duration(hours: 9),
      );
      expect(
        reminderFireTime(event, _now),
        DateTime.utc(2026, 10, 24, 11).toLocal(),
      );
    });
  });

  group('reminderFor', () {
    test('a vote closes, an event starts', () {
      final due = _now.add(const Duration(days: 3));
      final vote = _vote('v', due);
      final event = _event('e', due);
      final dayBefore = due.subtract(const Duration(hours: 24));

      expect(reminderFor(vote, dayBefore).body, 'Voting closes in 24 hours.');
      expect(reminderFor(event, dayBefore).body, 'Starts in 24 hours.');
      expect(
        reminderFor(vote, due.subtract(const Duration(hours: 1))).body,
        'Voting closes in 1 hour.',
      );
    });

    test('an all-day event names no hour it does not know', () {
      final day = DateTime(2026, 10, 25);
      final reminder = reminderFor(
        _event('e', day, allDay: true),
        DateTime(2026, 10, 24, 9),
      );
      expect(reminder.body, 'Happening tomorrow.');
      expect(reminder.title, 'Event e');
      expect(reminder.key, 'event:e');
    });
  });

  group('planReminders', () {
    final far = _now.add(const Duration(days: 5));
    final farFire = far.subtract(const Duration(hours: 24));

    test('only opted-in items are scheduled, and inputs are untouched', () {
      final items = [_vote('a', far), _vote('b', far)];
      final optedIn = {'vote:a': farFire};

      final plan = planReminders(
        items: items,
        optedIn: optedIn,
        loadedKinds: AgendaKind.values.toSet(),
        now: _now,
      );

      expect(plan.toSchedule.map((r) => r.key), ['vote:a']);
      expect(plan.toCancel, isEmpty);
      expect(plan.next, {'vote:a': farFire});
      expect(items.length, 2);
      expect(optedIn, {'vote:a': farFire});
    });

    test('a deadline that moved is reminded at the new time', () {
      final moved = far.add(const Duration(days: 2));
      final plan = planReminders(
        items: [_vote('a', moved)],
        optedIn: {'vote:a': farFire},
        loadedKinds: AgendaKind.values.toSet(),
        now: _now,
      );

      final newFire = moved.subtract(const Duration(hours: 24));
      expect(plan.toSchedule.single.fireAt, newFire);
      expect(plan.next, {'vote:a': newFire});
    });

    test('a deadline pulled too close is withdrawn and forgotten', () {
      final plan = planReminders(
        items: [_vote('a', _now.add(const Duration(minutes: 30)))],
        optedIn: {'vote:a': farFire},
        loadedKinds: AgendaKind.values.toSet(),
        now: _now,
      );

      expect(plan.toSchedule, isEmpty);
      expect(plan.toCancel, {'vote:a'});
      expect(plan.next, isEmpty);
    });

    test('an item gone after a successful load is cancelled', () {
      final plan = planReminders(
        items: const [],
        optedIn: {'vote:withdrawn': farFire},
        loadedKinds: {AgendaKind.vote},
        now: _now,
      );

      expect(plan.toCancel, {'vote:withdrawn'});
      expect(plan.next, isEmpty);
    });

    test('an item missing because its source failed is left alone', () {
      // A vote list that did not arrive is not a vote list that is empty.
      final plan = planReminders(
        items: [_event('e', far)],
        optedIn: {'vote:a': farFire, 'event:e': farFire},
        loadedKinds: {AgendaKind.event},
        now: _now,
      );

      expect(plan.toCancel, isEmpty);
      expect(plan.next, {'vote:a': farFire, 'event:e': farFire});
      expect(plan.toSchedule.map((r) => r.key), ['event:e']);
    });

    test('a reminder that already went off is neither repeated nor pulled', () {
      // Re-planning it now would pick the hour-before tier and ring twice.
      final due = _now.add(const Duration(hours: 10));
      final fired = due.subtract(const Duration(hours: 24));
      final stillThere = planReminders(
        items: [_vote('a', due)],
        optedIn: {'vote:a': fired},
        loadedKinds: AgendaKind.values.toSet(),
        now: _now,
      );
      expect(stillThere.toSchedule, isEmpty);
      expect(stillThere.toCancel, isEmpty);
      expect(stillThere.next, {'vote:a': fired});

      // Once its item is gone, the opt-in is dropped — but nothing is
      // cancelled: the notification the reader was shown stays theirs.
      final gone = planReminders(
        items: const [],
        optedIn: {'vote:a': fired},
        loadedKinds: AgendaKind.values.toSet(),
        now: _now,
      );
      expect(gone.toCancel, isEmpty);
      expect(gone.next, isEmpty);
    });
  });
}
