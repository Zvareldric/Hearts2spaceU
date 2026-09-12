import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/features/schedule/data/calendar_event_repository.dart';

String _payload(List<Map<String, Object?>> rows) => jsonEncode(rows);

Map<String, Object?> _row({
  String id = 'e1',
  String title = 'Inkigayo Live in Tokyo',
  String date = '2026-09-23',
  Object? time = '18:00',
  String cat = 'tv',
  String timezone = 'Asia/Tokyo',
  String note = '',
  String source = '',
  bool yearly = false,
}) => {
  'id': id,
  'title': title,
  'date': date,
  'time': time,
  'cat': cat,
  'timezone': timezone,
  'note': note,
  'source': source,
  'yearly': yearly,
  'minor': false,
};

void main() {
  group('parseEvents', () {
    test('reads a row into an event, zone and all', () {
      final event = CalendarEventRepository.parseEvents(
        _payload([_row(source: 'https://example.com/post')]),
      ).single;

      expect(event.id, 'e1');
      expect(event.title, 'Inkigayo Live in Tokyo');
      expect(event.startDateTime, DateTime(2026, 9, 23, 18));
      expect(event.allDay, isFalse);
      expect(event.zoneLabel, 'JST');
      expect(event.zoneOffset, const Duration(hours: 9));
      expect(event.officialUrl, 'https://example.com/post');
      // "tv" is the feed's word for what this app already calls a broadcast.
      expect(event.type, 'broadcast');
    });

    test('a row with no time becomes all-day, not midnight', () {
      // The feed leaves `time` out when the time is not known. Storing 00:00
      // and printing it would state something it never said.
      final event = CalendarEventRepository.parseEvents(
        _payload([_row(time: null)]),
      ).single;

      expect(event.allDay, isTrue);
      expect(event.startDateTime, DateTime(2026, 9, 23));
      // Nothing to label, so no zone travels with it either.
      expect(event.zoneLabel, isNull);
    });

    test('a zone it does not know keeps its name and gets no offset', () {
      // Europe/Paris shifts with daylight saving, so there is no one offset to
      // convert it by — it is shown as published instead of shifted by a guess.
      final event = CalendarEventRepository.parseEvents(
        _payload([_row(timezone: 'Europe/Paris')]),
      ).single;

      expect(event.zoneLabel, 'Europe/Paris');
      expect(event.zoneOffset, isNull);
      expect(event.localStart, event.startDateTime);
    });

    test('drops a link that is not https, but keeps the event', () {
      // One unsafe link in someone else's feed is no reason to hide the event.
      final event = CalendarEventRepository.parseEvents(
        _payload([_row(source: 'http://insecure.example.com')]),
      ).single;

      expect(event.officialUrl, isNull);
      expect(event.title, 'Inkigayo Live in Tokyo');
    });

    test('skips a recurring row rather than dating it to a birth year', () {
      // The birthdays in this feed are stored on the date they first happened —
      // 2006 through 2010 — so importing them would bury eight events two
      // decades in the past. Birthdays live on Member Detail anyway.
      final events = CalendarEventRepository.parseEvents(
        _payload([
          _row(id: 'bday', date: '2006-03-28', yearly: true),
          _row(id: 'real'),
        ]),
      );

      expect(events.map((e) => e.id), ['real']);
    });

    test('skips an unreadable row and keeps the rest of the schedule', () {
      // This is a feed the app does not own: it changes without notice, and one
      // row it cannot make sense of must not empty the Schedule tab.
      final events = CalendarEventRepository.parseEvents(
        jsonEncode([
          _row(id: 'good-1'),
          {'title': 'no id at all', 'date': '2026-09-23'},
          {'id': 'bad-date', 'title': 'x', 'date': 'not a date'},
          'not even an object',
          _row(id: 'good-2'),
        ]),
      );

      expect(events.map((e) => e.id), ['good-1', 'good-2']);
    });

    test('a payload that is not an array is a real failure', () {
      // The feed being broken as a whole is different from one bad row, and the
      // UI should say the schedule could not be loaded rather than show none.
      expect(
        () => CalendarEventRepository.parseEvents('{"events": []}'),
        throwsA(isA<FormatException>()),
      );
    });

    test('keeps a category the app has no word for', () {
      // TypeBadge renders an unmapped type in a neutral pill, so the app does
      // not have to learn every category the calendar will ever add.
      final event = CalendarEventRepository.parseEvents(
        _payload([_row(cat: 'ambassador')]),
      ).single;

      expect(event.type, 'ambassador');
    });
  });

  group('zoneFor', () {
    test('maps the zones the feed actually uses', () {
      expect(CalendarEventRepository.zoneFor('Asia/Seoul'), (
        'KST',
        const Duration(hours: 9),
      ));
      expect(CalendarEventRepository.zoneFor('Asia/Jakarta'), (
        'WIB',
        const Duration(hours: 7),
      ));
    });

    test('a missing zone is no zone', () {
      expect(CalendarEventRepository.zoneFor(''), isNull);
      expect(CalendarEventRepository.zoneFor(null), isNull);
    });
  });

  test('the real feed shape still parses', () {
    // A miniature of an actual response, field for field, so a rename upstream
    // shows up here as a failing test rather than as an empty Schedule tab.
    const real = '''
    [{"id":"605d1b6f","title":"Seventeen Autumn 2026 Issue Magazine Release",
      "date":"2026-09-01","time":"00:00","cat":"ambassador","note":"",
      "source":"","tweet":"","tweet_date":"","added_at":"2026-06-22T00:00:00.000Z",
      "updated_at":"2026-07-07T00:00:00.000Z","created_at":"2026-06-22T11:00:11.963Z",
      "timezone":"Asia/Tokyo","yearly":false,"minor":false,"event_id":848}]
    ''';

    final event = CalendarEventRepository.parseEvents(real).single;

    expect(event.id, '605d1b6f');
    // 00:00 is a time the feed means, not a missing one — it is written out.
    expect(event.allDay, isFalse);
    expect(event.startDateTime, DateTime(2026, 9, 1));
    expect(event.zoneLabel, 'JST');
  });
}
