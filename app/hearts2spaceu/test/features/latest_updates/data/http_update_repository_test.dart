import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/features/latest_updates/data/http_update_repository.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Builds a repository backed by a fake HTTP client — no real network is ever
/// touched, so these tests are fast and work offline.
HttpUpdateRepository _repositoryReturning(String body, {int statusCode = 200}) {
  return HttpUpdateRepository(
    client: MockClient((request) async => http.Response(body, statusCode)),
  );
}

void main() {
  group('HttpUpdateRepository.parseUpdates', () {
    test('parses a fully-populated update', () {
      const raw = '''
      [
        {
          "id": "u1",
          "title": "Japanese debut announced",
          "publishedAt": "2026-07-05T00:00:00Z",
          "summary": "A short teaser.",
          "body": "The full story.",
          "category": "announcement",
          "sourceUrl": "https://example.com/u1",
          "imageUrl": "https://example.com/u1.png"
        }
      ]
      ''';

      final update = HttpUpdateRepository.parseUpdates(raw).single;

      expect(update.id, 'u1');
      expect(update.title, 'Japanese debut announced');
      expect(update.publishedAt, DateTime.utc(2026, 7, 5));
      expect(update.summary, 'A short teaser.');
      expect(update.body, 'The full story.');
      expect(update.category, 'announcement');
      expect(update.sourceUrl, 'https://example.com/u1');
      expect(update.imageUrl, 'https://example.com/u1.png');
    });

    test('defaults optional fields when absent', () {
      const raw =
          '[{"id": "u2", "title": "Minimal", "publishedAt": "2026-01-01T00:00:00Z"}]';

      final update = HttpUpdateRepository.parseUpdates(raw).single;

      expect(update.summary, isNull);
      expect(update.body, isNull);
      expect(update.category, isNull);
      expect(update.sourceUrl, isNull);
      expect(update.imageUrl, isNull);
    });

    test('returns an empty list for an empty array', () {
      expect(HttpUpdateRepository.parseUpdates('[]'), isEmpty);
    });

    test('throws FormatException when the root is not an array', () {
      expect(
        () => HttpUpdateRepository.parseUpdates('{"id": "x"}'),
        throwsFormatException,
      );
    });

    test('throws when a required field is missing', () {
      expect(
        () => HttpUpdateRepository.parseUpdates(
          '[{"title": "No id", "publishedAt": "2026-01-01T00:00:00Z"}]',
        ),
        throwsA(isA<TypeError>()),
      );
    });

    test('throws FormatException when publishedAt is malformed', () {
      expect(
        () => HttpUpdateRepository.parseUpdates(
          '[{"id": "u", "title": "T", "publishedAt": "not-a-date"}]',
        ),
        throwsFormatException,
      );
    });
  });

  group('HttpUpdateRepository.getUpdates', () {
    test('returns parsed updates on HTTP 200', () async {
      final repository = _repositoryReturning(
        '[{"id": "u1", "title": "Hello", "publishedAt": "2026-07-05T00:00:00Z"}]',
      );

      final updates = await repository.getUpdates();

      expect(updates, hasLength(1));
      expect(updates.single.title, 'Hello');
    });

    test('throws on a non-200 response', () async {
      final repository = _repositoryReturning('Not Found', statusCode: 404);

      expect(repository.getUpdates(), throwsA(isA<http.ClientException>()));
    });

    test('throws on a malformed body even with HTTP 200', () async {
      final repository = _repositoryReturning('this is not json');

      expect(repository.getUpdates(), throwsFormatException);
    });

    test('decodes non-ASCII text as UTF-8', () async {
      // Guards the bodyBytes+utf8 choice: response.body would assume latin-1
      // when the server omits a charset and mangle these characters.
      const title = '하츠투하츠 — “Iconic Heart”';
      final repository = HttpUpdateRepository(
        client: MockClient(
          (request) async => http.Response.bytes(
            utf8.encode(
              '[{"id":"u","title":"$title","publishedAt":"2026-07-05T00:00:00Z"}]',
            ),
            200,
          ),
        ),
      );

      final updates = await repository.getUpdates();

      expect(updates.single.title, title);
    });
  });
}
