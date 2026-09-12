import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/features/schedule/presentation/event_date_format.dart';

void main() {
  final august = DateTime(2026, 8, 5, 20, 28);

  test('shows date and time by default', () {
    expect(formatEventDateTime(august), '05/08/2026 · 20:28');
  });

  test('omits the time for an all-day event', () {
    expect(formatEventDateTime(august, allDay: true), '05/08/2026');
  });

  test('never prints a misleading 00:00 for an all-day event', () {
    // The whole reason `allDay` exists: a date-only entry stored as midnight
    // must not claim the event happens at midnight.
    final midnight = DateTime(2026, 8, 12);

    expect(formatEventDateTime(midnight, allDay: true), '12/08/2026');
    expect(formatEventDateTime(midnight), '12/08/2026 · 00:00');
  });

  test('pads single-digit day, month, hour and minute', () {
    expect(
      formatEventDateTime(DateTime(2026, 1, 2, 3, 4)),
      '02/01/2026 · 03:04',
    );
  });

  group('formatClock', () {
    // The reader's own zone is whatever machine runs the suite, so every
    // expectation below is written relative to it rather than hard-coded.
    final readerOffset = DateTime.now().timeZoneOffset;
    final elsewhere = readerOffset + const Duration(hours: 2);

    String clock({
      bool allDay = false,
      String? zoneLabel,
      Duration? zoneOffset,
    }) => formatClock(
      published: august,
      allDay: allDay,
      zoneLabel: zoneLabel,
      zoneOffset: zoneOffset,
    );

    test('an all-day event has no time at all', () {
      expect(clock(allDay: true, zoneLabel: 'KST', zoneOffset: elsewhere), '');
    });

    test('a time with no recorded zone prints bare, as it always has', () {
      expect(clock(), '20:28');
    });

    test(
      'a named zone with no usable offset shows only what was published',
      () {
        // A daylight-saving zone: converting it could be an hour out, so it is
        // labelled and left alone rather than silently shifted.
        expect(clock(zoneLabel: 'CET'), '20:28 CET');
      },
    );

    test('a reader already on the event clock is not told twice', () {
      expect(clock(zoneLabel: 'KST', zoneOffset: readerOffset), '20:28 KST');
    });

    test('elsewhere, the reader clock leads and the published one follows', () {
      final line = clock(zoneLabel: 'KST', zoneOffset: elsewhere);

      // The published time is never dropped — fans check the app against
      // posters written in it.
      expect(line, endsWith('(20:28 KST)'));
      // And it leads with the time two hours earlier on the reader's clock.
      expect(line, startsWith('18:28 '));
    });
  });

  group('formatFetchedAt', () {
    final now = DateTime(2026, 9, 12, 12);

    test('says how old the copy on screen is, coarsely', () {
      expect(
        formatFetchedAt(now.subtract(const Duration(seconds: 20)), now),
        'Updated just now',
      );
      expect(
        formatFetchedAt(now.subtract(const Duration(minutes: 5)), now),
        'Updated 5 minutes ago',
      );
      expect(
        formatFetchedAt(now.subtract(const Duration(hours: 3)), now),
        'Updated 3 hours ago',
      );
      expect(
        formatFetchedAt(now.subtract(const Duration(days: 2)), now),
        'Updated 2 days ago',
      );
    });

    test('says "1 hour", not "1 hours"', () {
      expect(
        formatFetchedAt(now.subtract(const Duration(hours: 1)), now),
        'Updated 1 hour ago',
      );
    });

    test('a stamp from the future reads as fresh, not as nonsense', () {
      // Device clocks get set wrong. "Updated in -3 hours" helps nobody.
      expect(
        formatFetchedAt(now.add(const Duration(hours: 3)), now),
        'Updated just now',
      );
    });
  });
}
