import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/features/streaming_hub/data/asset_platform_repository.dart';

void main() {
  group('AssetPlatformRepository.parsePlatforms', () {
    test('parses a fully-populated platform', () {
      const raw = '''
      [
        {
          "id": "instagram",
          "name": "Instagram",
          "url": "https://www.instagram.com/hearts2hearts",
          "category": "social",
          "handle": "@hearts2hearts"
        }
      ]
      ''';

      final platform = AssetPlatformRepository.parsePlatforms(raw).single;

      expect(platform.id, 'instagram');
      expect(platform.name, 'Instagram');
      expect(platform.url, 'https://www.instagram.com/hearts2hearts');
      expect(platform.category, 'social');
      expect(platform.handle, '@hearts2hearts');
    });

    test('leaves handle null when absent', () {
      const raw =
          '[{"id": "spotify", "name": "Spotify", "url": "https://open.spotify.com/x", "category": "music"}]';

      expect(AssetPlatformRepository.parsePlatforms(raw).single.handle, isNull);
    });

    test('rejects a non-https URL', () {
      // The security rule enforced at the boundary: a bad link must never
      // reach the domain, let alone the launcher.
      const raw =
          '[{"id": "x", "name": "X", "url": "http://example.com", "category": "social"}]';

      expect(
        () => AssetPlatformRepository.parsePlatforms(raw),
        throwsFormatException,
      );
    });

    test('rejects a javascript: URL', () {
      const raw =
          '[{"id": "x", "name": "X", "url": "javascript:alert(1)", "category": "social"}]';

      expect(
        () => AssetPlatformRepository.parsePlatforms(raw),
        throwsFormatException,
      );
    });

    test('throws when a required field is missing', () {
      const raw =
          '[{"name": "No id", "url": "https://example.com", "category": "social"}]';

      expect(
        () => AssetPlatformRepository.parsePlatforms(raw),
        throwsA(isA<TypeError>()),
      );
    });

    test('throws FormatException when the root is not an array', () {
      expect(
        () => AssetPlatformRepository.parsePlatforms('{"id": "x"}'),
        throwsFormatException,
      );
    });

    test('returns an empty list for an empty array', () {
      expect(AssetPlatformRepository.parsePlatforms('[]'), isEmpty);
    });
  });

  group('AssetPlatformRepository.getPlatforms', () {
    setUp(TestWidgetsFlutterBinding.ensureInitialized);

    test('loads the real bundled asset', () async {
      const repository = AssetPlatformRepository();

      final platforms = await repository.getPlatforms();

      // Not pinning an exact roster: the PO curates platforms.json freely.
      // This proves the shipped asset parses and passes the https rule.
      expect(platforms, isNotEmpty);
      expect(platforms.every((p) => p.url.startsWith('https://')), isTrue);
      expect(platforms.every((p) => p.name.isNotEmpty), isTrue);
    });
  });
}
