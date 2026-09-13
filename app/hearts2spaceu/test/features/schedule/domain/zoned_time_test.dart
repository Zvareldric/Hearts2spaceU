import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/features/schedule/domain/event.dart';
import 'package:hearts2spaceu/features/schedule/domain/zoned_time.dart';

void main() {
  // Every assertion here is written against UTC, so the suite gives the same
  // answer on a laptop in Jakarta, a CI runner in UTC, and a phone in Seoul.
  const kst = Duration(hours: 9);

  group('toReaderClock', () {
    test('reads a wall clock as the instant its own zone means', () {
      // 18:00 in Seoul is 09:00 UTC. Nothing here depends on where the test
      // happens to run — only the offset it was told about.
      final local = toReaderClock(DateTime(2026, 9, 9, 18), kst);

      expect(local.toUtc(), DateTime.utc(2026, 9, 9, 9));
    });

    test('a zone it cannot pin down is left exactly as published', () {
      // Better one honest time than a converted one that may be an hour out.
      final published = DateTime(2026, 9, 9, 18);

      expect(toReaderClock(published, null), published);
    });

    test('carries a conversion across midnight into the previous day', () {
      // 00:30 KST is the evening before almost everywhere west of Korea. This
      // is the case that makes local time unsafe to group the schedule by.
      final local = toReaderClock(DateTime(2026, 9, 10, 0, 30), kst);

      expect(local.toUtc(), DateTime.utc(2026, 9, 9, 15, 30));
    });
  });

  group('Event.localStart', () {
    Event event({String? zoneLabel, Duration? zoneOffset}) => Event(
      id: 'e',
      title: 'Fansign',
      startDateTime: DateTime(2026, 9, 9, 18),
      zoneLabel: zoneLabel,
      zoneOffset: zoneOffset,
    );

    test('converts when the zone is known', () {
      expect(
        event(zoneLabel: 'KST', zoneOffset: kst).localStart.toUtc(),
        DateTime.utc(2026, 9, 9, 9),
      );
    });

    test('an event with no zone behaves exactly as it did before zones', () {
      // The bundled events.json records none, so this is the whole existing
      // data set: it must be untouched by the field being added.
      expect(event().localStart, DateTime(2026, 9, 9, 18));
    });
  });
}
