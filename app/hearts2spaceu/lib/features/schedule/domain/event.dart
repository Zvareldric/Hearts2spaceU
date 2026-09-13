import 'zoned_time.dart';

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
    this.zoneLabel,
    this.zoneOffset,
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

  /// Short name of the clock [startDateTime] is written on, e.g. `KST`.
  ///
  /// Null for the bundled data, which records no zone at all — those events
  /// then display exactly as they always have.
  final String? zoneLabel;

  /// How far ahead of UTC [zoneLabel] runs.
  ///
  /// Null when the zone is named but its offset cannot be pinned down — a zone
  /// with daylight saving, say. The event then shows its own clock and no
  /// converted one, rather than a converted time that might be an hour out.
  final Duration? zoneOffset;

  /// [startDateTime] moved onto the reader's own clock.
  ///
  /// Falls back to the original when there is nothing to convert with, so an
  /// event that records no zone behaves exactly as it did before zones existed.
  ///
  /// Note this is deliberately NOT what the schedule sorts or groups by. A
  /// concert at 00:30 KST is a Tokyo-Thursday event even for a reader whose
  /// clock says Wednesday evening, and fans match the app against calendars
  /// published in the event's own country.
  DateTime get localStart => toReaderClock(startDateTime, zoneOffset);
}
