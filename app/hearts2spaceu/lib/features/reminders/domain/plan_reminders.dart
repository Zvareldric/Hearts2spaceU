import '../../agenda/domain/agenda_item.dart';
import 'reminder.dart';

/// The key a reminder for [item] is stored under: `event:<id>` or `vote:<id>`.
String reminderKey(AgendaItem item) => '${item.kind.name}:${item.id}';

/// When to remind about [item], or null when it is too close to be worth it.
///
/// Tiered so it never schedules something useless (docs/specs/reminders.md §5):
/// a day before when that is still ahead, an hour before when only that is,
/// and nothing when both have passed. The fan who finds a vote twenty hours
/// before it closes is exactly who most needs reminding; a single fixed lead
/// would refuse them in silence.
///
/// An all-day event is the exception. Its time is a midnight the source never
/// gave, so "a day before" would be midnight the day before — and waking
/// someone at 00:00 about tomorrow is how notifications get switched off for
/// good. It fires at 09:00 the day before instead, or not at all once that
/// has passed.
DateTime? reminderFireTime(AgendaItem item, DateTime now) {
  if (item.isAllDay) {
    final day = item.dueAt;
    final morningBefore = DateTime(day.year, day.month, day.day - 1, 9);
    return morningBefore.isAfter(now) ? morningBefore : null;
  }

  // The real instant, not the printed clock: a KST event read on a Jakarta
  // clock would otherwise be reminded two hours late.
  final due = item.localDue;
  for (final lead in const [Duration(hours: 24), Duration(hours: 1)]) {
    final candidate = due.subtract(lead);
    if (candidate.isAfter(now)) return candidate;
  }
  return null;
}

/// The notification for [item], firing at [fireAt].
///
/// Says what happens and when, with the verb that fits: a vote *closes*, an
/// event *starts* — the same distinction the Agenda draws on every row.
Reminder reminderFor(AgendaItem item, DateTime fireAt) {
  // Always one of the two tiers, so always whole hours.
  final hours = item.localDue.difference(fireAt).inHours;
  final when = 'in $hours hour${hours == 1 ? '' : 's'}';

  return Reminder(
    key: reminderKey(item),
    fireAt: fireAt,
    title: item.title,
    body: switch (item.kind) {
      AgendaKind.vote => 'Voting closes $when.',
      AgendaKind.event when item.isAllDay => 'Happening tomorrow.',
      AgendaKind.event => 'Starts $when.',
    },
  );
}

/// What reconciling the reminders against fresh data should change.
class ReminderPlan {
  const ReminderPlan({
    required this.toSchedule,
    required this.toCancel,
    required this.next,
  });

  /// Reminders to (re)schedule. Scheduling under the same key replaces, so
  /// putting one that is already pending back in is harmless.
  final List<Reminder> toSchedule;

  /// Keys whose pending reminder must be withdrawn.
  final Set<String> toCancel;

  /// The opt-ins to keep, each with the instant it is set to fire.
  final Map<String, DateTime> next;
}

/// Lines the user's reminders up with the agenda as it now stands.
///
/// Pure: [now] is a parameter, and neither input is changed. The result is the
/// one truth about what should be scheduled; the caller only applies it.
///
/// For each opted-in key:
/// - **Its item is still there, reminder still ahead** — re-planned from the
///   item, so a vote whose deadline moved is reminded at the new time. If it
///   has become too close, it is withdrawn.
/// - **Its item is still there, reminder already gone off** — left alone. One
///   reminder per item: re-planning now would pick the one-hour tier and remind
///   a second time.
/// - **Its item is gone, and its source loaded** — the vote was withdrawn or
///   the event cancelled, so a reminder still ahead is cancelled and the
///   opt-in dropped.
/// - **Its item is gone because its source failed to load** — nothing
///   happens. A vote list that did not arrive is not a vote list that is
///   empty (docs/specs/reminders.md §4).
///
/// A reminder that has already been shown is never withdrawn; once the system
/// has displayed it, it belongs to the reader.
ReminderPlan planReminders({
  required List<AgendaItem> items,
  required Map<String, DateTime> optedIn,
  required Set<AgendaKind> loadedKinds,
  required DateTime now,
}) {
  final byKey = {for (final item in items) reminderKey(item): item};
  final toSchedule = <Reminder>[];
  final toCancel = <String>{};
  final next = <String, DateTime>{};

  for (final MapEntry(key: key, value: firesAt) in optedIn.entries) {
    final item = byKey[key];
    final stillAhead = firesAt.isAfter(now);

    if (item == null) {
      final kind = AgendaKind.values.where((k) => key.startsWith('${k.name}:'));
      final sourceLoaded = kind.isNotEmpty && loadedKinds.contains(kind.first);
      if (!sourceLoaded) {
        next[key] = firesAt;
      } else if (stillAhead) {
        toCancel.add(key);
      }
      continue;
    }

    if (!stillAhead) {
      next[key] = firesAt;
      continue;
    }

    final replanned = reminderFireTime(item, now);
    if (replanned == null) {
      toCancel.add(key);
      continue;
    }
    next[key] = replanned;
    toSchedule.add(reminderFor(item, replanned));
  }

  return ReminderPlan(toSchedule: toSchedule, toCancel: toCancel, next: next);
}
