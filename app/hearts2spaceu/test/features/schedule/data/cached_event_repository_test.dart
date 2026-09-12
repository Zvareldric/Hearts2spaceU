import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/features/schedule/data/cached_event_repository.dart';
import 'package:hearts2spaceu/features/schedule/data/calendar_event_repository.dart';
import 'package:hearts2spaceu/features/schedule/data/event_cache.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

String _feed(String id) => jsonEncode([
  {
    'id': id,
    'title': 'Fansign in Tokyo',
    'date': '2026-09-23',
    'time': '18:00',
    'cat': 'fansign',
    'timezone': 'Asia/Tokyo',
    'yearly': false,
  },
]);

/// Counts calls so a test can prove the network was not touched.
class _CountingClient extends http.BaseClient {
  _CountingClient(this._body, {this.fails = false});

  final String _body;
  final bool fails;
  int calls = 0;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    calls++;
    if (fails) throw const SocketishFailure();
    return http.StreamedResponse(
      Stream.value(utf8.encode(_body)),
      200,
      request: request,
    );
  }
}

class SocketishFailure implements Exception {
  const SocketishFailure();
}

CachedEventRepository _repo(_CountingClient client) => CachedEventRepository(
  remote: CalendarEventRepository(client: client, url: 'https://example.com/f'),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('the first load fetches, and stores what it fetched', () async {
    final client = _CountingClient(_feed('first'));

    final events = await _repo(client).getEvents();

    expect(events.single.id, 'first');
    expect(client.calls, 1);
    expect(await const EventCache().read(), isNotNull);
  });

  test('a later load comes from the cache, not the network', () async {
    // What "cache locally, refresh on demand" buys: the Schedule tab opens on
    // what is already there, instantly and without a connection.
    final first = _CountingClient(_feed('stored'));
    await _repo(first).getEvents();

    final second = _CountingClient(_feed('newer'));
    final events = await _repo(second).getEvents();

    expect(events.single.id, 'stored');
    expect(second.calls, 0, reason: 'nothing should have gone to the network');
  });

  test('forceRefresh goes past the cache and replaces it', () async {
    await _repo(_CountingClient(_feed('old'))).getEvents();

    final client = _CountingClient(_feed('new'));
    final events = await _repo(client).getEvents(forceRefresh: true);

    expect(events.single.id, 'new');
    expect(client.calls, 1);
    // And the newer copy is what the next plain load will serve.
    final again = _CountingClient(_feed('unused'));
    expect((await _repo(again).getEvents()).single.id, 'new');
  });

  test('a failed refresh throws rather than emptying the stored copy', () async {
    // The page catches this and keeps the list on screen. What must not happen
    // is the saved schedule being discarded because the network blinked.
    await _repo(_CountingClient(_feed('saved'))).getEvents();

    await expectLater(
      _repo(_CountingClient('', fails: true)).getEvents(forceRefresh: true),
      throwsA(isA<SocketishFailure>()),
    );

    final events = await _repo(_CountingClient('', fails: true)).getEvents();
    expect(events.single.id, 'saved');
  });

  test('a first load with no network and no cache fails loudly', () async {
    // Nothing to show and nothing stored: the page owes the reader an error
    // state with a Retry, not a silent empty list.
    await expectLater(
      _repo(_CountingClient('', fails: true)).getEvents(),
      throwsA(isA<SocketishFailure>()),
    );
  });

  test('a corrupt timestamp reads as no cache rather than a crash', () async {
    await _repo(_CountingClient(_feed('stored'))).getEvents();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(EventCache.fetchedAtKey, 'not a date');

    expect(await const EventCache().read(), isNull);
  });
}
