/// Moves a wall-clock time written in one zone onto the reader's own clock.
///
/// [wallClock] carries no zone of its own — it is the time exactly as the
/// source printed it — so [zoneOffset] says which clock that was. A null offset
/// means the zone could not be pinned down (one with daylight saving, say), and
/// the time is returned untouched: better to show only the published time than
/// a converted one that might be an hour out.
DateTime toReaderClock(DateTime wallClock, Duration? zoneOffset) {
  if (zoneOffset == null) return wallClock;

  return DateTime.utc(
    wallClock.year,
    wallClock.month,
    wallClock.day,
    wallClock.hour,
    wallClock.minute,
  ).subtract(zoneOffset).toLocal();
}
