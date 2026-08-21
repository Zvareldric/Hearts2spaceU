/// What one agenda row is, whichever capability it came from.
///
/// The two sources say different things with their dates — an event's is when
/// something *starts*, a vote's is when something *ends* — so the kind travels
/// with the row: it is what lets the presentation layer pick the right verb
/// (docs/specs/agenda.md §4).
enum AgendaKind { event, vote }

/// One time-bound thing worth following, flattened to a single shape.
///
/// Pure and immutable, and deliberately free of any wording: how long is left
/// is a sentence, and sentences belong to the presentation layer (the same
/// rule Voting Hub follows, docs/specs/voting-hub.md §5).
class AgendaItem {
  const AgendaItem({
    required this.kind,
    required this.id,
    required this.title,
    required this.dueAt,
    this.subtitle,
    this.isAllDay = false,
    this.isUpcomingVote = false,
    this.url,
  });

  final AgendaKind kind;

  /// The source item's own id — an event id or a campaign id.
  final String id;

  final String title;

  /// One line of context: where an event happens, or who runs a vote.
  final String? subtitle;

  /// The deadline this row is sorted by: an event's start, a vote's close.
  final DateTime dueAt;

  /// True when the event's source gave a date but no time, so no time is
  /// printed for it (docs/specs/schedule.md §4).
  final bool isAllDay;

  /// True for a vote that is announced but has not opened yet.
  final bool isUpcomingVote;

  /// Where a vote is cast. Null for events, which open their own detail page.
  final String? url;
}
