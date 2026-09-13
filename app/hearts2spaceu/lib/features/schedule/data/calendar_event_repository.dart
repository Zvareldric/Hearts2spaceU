import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../shared/services/url_opener.dart';
import '../domain/event.dart';
import '../domain/event_repository.dart';

/// Fetches the schedule from the Hearts2Hearts Calendar's public API.
///
/// The first repository in the app reading a source it does not own. Two rules
/// follow from that and shape everything below.
///
/// **One bad row must not take down the schedule.** A bundled asset is ours, so
/// a malformed entry there is a bug worth failing loudly on; this feed is
/// maintained by other people and changes without notice, so a row the app
/// cannot make sense of is skipped and the rest still renders.
///
/// **Nothing is invented.** A row with no time becomes an all-day event rather
/// than one at midnight; a zone the app cannot pin an offset to keeps its label
/// and loses its conversion; a link that is not https is dropped rather than
/// opened.
class CalendarEventRepository implements EventRepository {
  CalendarEventRepository({http.Client? client, this.url = defaultUrl})
    : _client = client ?? http.Client();

  /// h2hcalendar.com, maintained by S2U Philippines. Credited in the app.
  static const defaultUrl = 'https://h2hcalendar.com/api/events';

  /// Generous: the feed is ~96 KB gzipped and has been seen to take 2.3s.
  static const timeout = Duration(seconds: 20);

  final http.Client _client;
  final String url;

  @override
  Future<List<Event>> getEvents({bool forceRefresh = false}) async =>
      parseEvents(await fetchRaw());

  /// The raw payload, before parsing.
  ///
  /// Separate from [getEvents] so a caching layer can keep the bytes it was
  /// given without having to turn parsed events back into JSON.
  Future<String> fetchRaw() async {
    final uri = Uri.parse(url);
    final response = await _client.get(uri).timeout(timeout);

    if (response.statusCode != 200) {
      throw http.ClientException(
        'Failed to load the calendar (HTTP ${response.statusCode})',
        uri,
      );
    }

    // bodyBytes + utf8: response.body guesses latin-1 without a charset header,
    // which mangles the Korean and Japanese titles this feed is full of.
    return utf8.decode(response.bodyBytes);
  }

  /// Parses the calendar payload into [Event]s.
  ///
  /// Pure and exposed so it can be unit-tested without any network. Throws only
  /// when the payload as a whole is not a JSON array; individual rows that
  /// cannot be read are skipped.
  static List<Event> parseEvents(String rawJson) {
    final decoded = jsonDecode(rawJson);
    if (decoded is! List) {
      throw const FormatException('The calendar must return a JSON array.');
    }

    final events = <Event>[];
    for (final item in decoded) {
      if (item is! Map<String, dynamic>) continue;
      // A recurring row stores the *first* occurrence — the member birthdays in
      // this feed sit in 2006-2010 — so its date says nothing about when it
      // next comes round. Birthdays already live on Member Detail, and the
      // schedule stays group activities only (docs/specs/schedule.md §4).
      if (item['yearly'] == true) continue;

      final event = _eventOrNull(item);
      if (event != null) events.add(event);
    }

    return List.unmodifiable(events);
  }

  static Event? _eventOrNull(Map<String, dynamic> json) {
    final id = json['id'];
    final title = json['title'];
    final date = json['date'];
    if (id is! String || title is! String || date is! String) return null;
    if (id.isEmpty || title.isEmpty) return null;

    final day = DateTime.tryParse(date);
    if (day == null) return null;

    final time = _timeOrNull(json['time']);
    final zone = zoneFor(json['timezone']);

    return Event(
      id: id,
      title: title,
      startDateTime: DateTime(
        day.year,
        day.month,
        day.day,
        time?.$1 ?? 0,
        time?.$2 ?? 0,
      ),
      allDay: time == null,
      type: typeFor(json['cat']),
      description: _textOrNull(json['note']),
      officialUrl: _httpsOrNull(json['source']),
      // An all-day event has no time to label, so it carries no zone either.
      zoneLabel: time == null ? null : zone?.$1,
      zoneOffset: time == null ? null : zone?.$2,
    );
  }

  /// `"18:00"` as (hour, minute). Null for a row with no time at all, which is
  /// how the feed says the time is not known.
  static (int, int)? _timeOrNull(Object? value) {
    if (value is! String) return null;
    final match = RegExp(r'^([01]?\d|2[0-3]):([0-5]\d)$').firstMatch(value);
    if (match == null) return null;
    return (int.parse(match.group(1)!), int.parse(match.group(2)!));
  }

  /// The zones the feed actually uses, each with the offset it always runs at.
  ///
  /// Deliberately a fixed table and not a time zone database: every zone here
  /// is one without daylight saving, so its offset is a constant, and the eight
  /// or so rows a year in zones that *do* shift are better shown unconverted
  /// than shifted by a guess. A zone missing from this table keeps its name and
  /// gets no offset, which [Event.localStart] handles by leaving the time be.
  static const _zones = <String, (String, Duration)>{
    'Asia/Seoul': ('KST', Duration(hours: 9)),
    'KST': ('KST', Duration(hours: 9)),
    'Asia/Tokyo': ('JST', Duration(hours: 9)),
    'JST': ('JST', Duration(hours: 9)),
    'Asia/Jakarta': ('WIB', Duration(hours: 7)),
    'Asia/Taipei': ('Taipei', Duration(hours: 8)),
    'Asia/Hong_Kong': ('HKT', Duration(hours: 8)),
    // The abbreviations name a fixed offset by definition — a source on summer
    // time writes PDT, not PST — so these convert safely too.
    'PST': ('PST', Duration(hours: -8)),
    'EST': ('EST', Duration(hours: -5)),
  };

  /// The label and offset for a zone as the feed spells it.
  ///
  /// An unrecognised zone keeps its own name and gets no offset, so it is
  /// labelled honestly and never converted.
  static (String, Duration?)? zoneFor(Object? value) {
    if (value is! String || value.isEmpty) return null;
    final known = _zones[value];
    if (known != null) return known;
    return (value, null);
  }

  /// The feed's categories, mapped onto the app's own vocabulary where one
  /// already means the same thing.
  ///
  /// The rest pass through untouched: [TypeBadge] gives an unmapped type a
  /// neutral pill and a readable label, so the app does not have to learn every
  /// category the calendar will ever add.
  static const _types = <String, String>{
    'tv': 'broadcast',
    'radio': 'broadcast',
    'fansign': 'fanmeeting',
    'music': 'release',
  };

  static String? typeFor(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return _types[value] ?? value;
  }

  static String? _textOrNull(Object? value) =>
      value is String && value.trim().isNotEmpty ? value.trim() : null;

  /// Keeps a source link only when it is safe to open.
  ///
  /// Dropped rather than thrown on: the link is the least important thing on
  /// the row, and one http:// entry in someone else's feed is no reason to hide
  /// the event it belongs to.
  static String? _httpsOrNull(Object? value) {
    final text = _textOrNull(value);
    if (text == null || !UrlOpener.isSafe(text)) return null;
    return text;
  }
}
