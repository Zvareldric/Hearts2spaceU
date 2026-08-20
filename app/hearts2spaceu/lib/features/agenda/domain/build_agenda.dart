import '../../schedule/domain/event.dart';
import '../../voting/domain/voting_campaign.dart';
import 'agenda_item.dart';

/// How close a deadline is, as the agenda groups them.
enum AgendaProximity { today, thisWeek, later }

/// One bucket of the agenda, in the order its items were given.
class AgendaGroup {
  const AgendaGroup({required this.proximity, required this.items});

  final AgendaProximity proximity;
  final List<AgendaItem> items;
}

/// Merges upcoming events and open votes into one list, soonest deadline first.
///
/// Pure and deterministic: `now` is passed in rather than read from the clock —
/// the same shape as `upcomingSorted` and `openAndUpcoming` — and neither input
/// list is mutated. `now` decides one thing only: whether a vote has opened yet.
///
/// It deliberately does **not** filter: `upcomingSorted` has already dropped
/// past events and `openAndUpcoming` has already dropped closed votes. Judging
/// "still relevant" a second time here would create a second place to change
/// every time either owner's rule moves (docs/specs/agenda.md §5).
///
/// Ties are settled the same way every time: at one instant a **vote comes
/// first** — a vote expires, while a missed event can still be caught up on —
/// and within a kind the source order is kept. `List.sort` is not stable, so
/// the original index does the keeping.
List<AgendaItem> buildAgenda({
  required List<Event> events,
  required List<VotingCampaign> votes,
  required DateTime now,
}) {
  final indexed = <(int, AgendaItem)>[];

  for (var i = 0; i < votes.length; i++) {
    final vote = votes[i];
    indexed.add((
      i,
      AgendaItem(
        kind: AgendaKind.vote,
        id: vote.id,
        title: vote.title,
        subtitle: vote.organizer,
        // A vote's deadline is when it *closes*; the wording that goes with
        // that lives in the presentation layer.
        dueAt: vote.closesAt,
        isUpcomingVote: vote.isUpcomingAt(now),
        url: vote.url,
      ),
    ));
  }

  for (var i = 0; i < events.length; i++) {
    final event = events[i];
    indexed.add((
      i,
      AgendaItem(
        kind: AgendaKind.event,
        id: event.id,
        title: event.title,
        subtitle: event.location,
        dueAt: event.startDateTime,
        isAllDay: event.allDay,
      ),
    ));
  }

  indexed.sort((a, b) {
    final byDeadline = a.$2.dueAt.compareTo(b.$2.dueAt);
    if (byDeadline != 0) return byDeadline;

    final byKind = _tieRank(a.$2.kind).compareTo(_tieRank(b.$2.kind));
    return byKind != 0 ? byKind : a.$1.compareTo(b.$1);
  });

  return [for (final (_, item) in indexed) item];
}

int _tieRank(AgendaKind kind) => switch (kind) {
  AgendaKind.vote => 0,
  AgendaKind.event => 1,
};

/// Splits [items] into Today / This week / Later, keeping their order.
///
/// Pure and deterministic; never mutates [items]. An empty bucket is left out
/// entirely rather than returned empty, so the page has no header to hide.
///
/// "This week" means the **next seven days**, not the calendar week: a calendar
/// week first demands an answer to "does the week start on Monday or Sunday",
/// a localisation question whose answer lives in `intl` — a dependency this
/// app does not have and does not need for a heading (docs/specs/agenda.md §5).
List<AgendaGroup> groupByProximity(List<AgendaItem> items, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));
  final weekEnd = now.add(const Duration(days: 7));

  final buckets = <AgendaProximity, List<AgendaItem>>{
    for (final proximity in AgendaProximity.values) proximity: <AgendaItem>[],
  };

  for (final item in items) {
    final proximity = item.dueAt.isBefore(tomorrow)
        ? AgendaProximity.today
        : (item.dueAt.isAfter(weekEnd)
              ? AgendaProximity.later
              : AgendaProximity.thisWeek);
    buckets[proximity]!.add(item);
  }

  return [
    for (final proximity in AgendaProximity.values)
      if (buckets[proximity]!.isNotEmpty)
        AgendaGroup(proximity: proximity, items: buckets[proximity]!),
  ];
}
