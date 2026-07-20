import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/features/schedule/data/asset_event_repository.dart';

void main() {
  group('AssetEventRepository.parseEvents', () {
    test('parses a fully-populated event', () {
      const raw = '''
      [
        {
          "id": "e1",
          "title": "Concert",
          "startDateTime": "2026-08-15T19:00:00",
          "type": "concert",
          "location": "Seoul",
          "description": "World tour",
          "officialUrl": "https://example.com/e1"
        }
      ]
      ''';

      final events = AssetEventRepository.parseEvents(raw);

      expect(events, hasLength(1));
      final event = events.first;
      expect(event.id, 'e1');
      expect(event.title, 'Concert');
      expect(event.startDateTime, DateTime(2026, 8, 15, 19, 0));
      expect(event.type, 'concert');
      expect(event.location, 'Seoul');
      expect(event.description, 'World tour');
      expect(event.officialUrl, 'https://example.com/e1');
    });

    test('defaults optional fields when absent', () {
      const raw =
          '[{"id": "e2", "title": "Broadcast", "startDateTime": "2026-01-01T00:00:00"}]';

      final event = AssetEventRepository.parseEvents(raw).single;

      expect(event.type, isNull);
      expect(event.location, isNull);
      expect(event.description, isNull);
      expect(event.officialUrl, isNull);
    });

    test('returns an empty list for an empty array', () {
      expect(AssetEventRepository.parseEvents('[]'), isEmpty);
    });

    test('throws FormatException when the root is not an array', () {
      expect(
        () => AssetEventRepository.parseEvents('{"id": "x"}'),
        throwsFormatException,
      );
    });

    test('throws when a required field is missing', () {
      expect(
        () => AssetEventRepository.parseEvents(
          '[{"title": "NoId", "startDateTime": "2026-01-01T00:00:00"}]',
        ),
        throwsA(isA<TypeError>()),
      );
    });

    test('throws FormatException when startDateTime is malformed', () {
      expect(
        () => AssetEventRepository.parseEvents(
          '[{"id": "e", "title": "T", "startDateTime": "not-a-date"}]',
        ),
        throwsFormatException,
      );
    });
  });

  group('AssetEventRepository.getEvents', () {
    setUp(TestWidgetsFlutterBinding.ensureInitialized);

    test('loads the bundled asset (currently empty)', () async {
      const repository = AssetEventRepository();

      expect(await repository.getEvents(), isEmpty);
    });
  });
}
