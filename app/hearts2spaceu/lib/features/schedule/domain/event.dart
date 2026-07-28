/// A scheduled Hearts2Hearts activity shown in the Schedule capability.
///
/// Pure, immutable domain entity — no knowledge of JSON, assets, or rendering.
/// [startDateTime] is parsed from an ISO string in the data layer and is
/// formatted for display only in the presentation layer.
class Event {
  const Event({
    required this.id,
    required this.title,
    required this.startDateTime,
    this.allDay = false,
    this.type,
    this.location,
    this.description,
    this.officialUrl,
  });

  /// Stable, unique identifier.
  final String id;

  /// Event title — the primary label shown in the list.
  final String title;

  /// When the event starts. The key field for filtering and sorting.
  final DateTime startDateTime;

  /// True when only the date is known, with no confirmed time.
  ///
  /// Most published schedules give a date alone. Rather than inventing a time
  /// and rendering a misleading "00:00", the app states plainly that the time
  /// is not known (docs/specs/schedule.md §4).
  final bool allDay;

  /// Kind of event, e.g. `concert`, `broadcast` (kept a String for MVP).
  final String? type;

  /// Where the event takes place.
  final String? location;

  /// Short description.
  final String? description;

  /// Official link for the event (stored; opening it is out of scope for now).
  final String? officialUrl;
}
