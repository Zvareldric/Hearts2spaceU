import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/features/schedule/data/calendar_event_repository.dart';

/// Checks the live h2hcalendar.com feed against what the app expects of it.
///
/// The Schedule depends on a calendar other fans maintain, with no contract
/// and no notice of changes (PRD risk register: "Fan source changes schema /
/// offline"). The app is built to survive a bad row, but a renamed field
/// would make *every* row bad, and the first anyone heard of it would be a
/// fan opening an empty Schedule. This runs weekly from
/// `.github/workflows/calendar-feed-check.yml` so the project hears first.
///
/// Lives outside `test/` on purpose: the ordinary suite must never touch the
/// network, and this is the one check whose whole point is to.
void main() {
  late List<dynamic> rows;

  setUpAll(() async {
    final raw = await CalendarEventRepository().fetchRaw();
    final decoded = jsonDecode(raw);
    expect(decoded, isA<List<dynamic>>(), reason: 'the feed is not a list');
    rows = decoded as List<dynamic>;
  });

  test('the feed still has rows', () {
    // It grew from 1,452 to 1,707 between September and October 2026. A
    // sudden drop towards zero means the endpoint changed, not the schedule.
    expect(rows.length, greaterThan(500));
  });

  test('the fields the app reads are still there', () {
    // The parser needs id, title and date on every row; time, timezone and
    // cat shape what it shows. Measured over all rows so one odd entry does
    // not fail the check, but a rename does.
    for (final field in ['id', 'title', 'date', 'time', 'timezone', 'cat']) {
      final present = rows
          .whereType<Map<String, dynamic>>()
          .where((row) => row.containsKey(field))
          .length;
      expect(
        present / rows.length,
        greaterThan(0.95),
        reason: '"$field" is missing from most rows — renamed upstream?',
      );
    }
  });

  test('almost every row still parses into an event', () {
    final raw = jsonEncode(rows);
    final events = CalendarEventRepository.parseEvents(raw);
    // Recurring rows (member birthdays) are skipped on purpose.
    final expected = rows
        .whereType<Map<String, dynamic>>()
        .where((row) => row['yearly'] != true)
        .length;

    expect(
      events.length / expected,
      greaterThan(0.95),
      reason:
          'only ${events.length} of $expected rows parsed — the row shape '
          'has changed',
    );
  });
}
