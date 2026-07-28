import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/features/awards/data/asset_award_repository.dart';
import 'package:hearts2spaceu/features/awards/domain/award.dart';

void main() {
  group('AssetAwardRepository.parseAwards', () {
    test('parses a fully-populated award', () {
      const raw = '''
      [
        {
          "id": "mama-2025",
          "title": "Best New Artist",
          "ceremony": "MAMA Awards",
          "year": 2025,
          "type": "award",
          "awardedOn": "2025-11-28T00:00:00",
          "work": "The Chase",
          "members": ["Carmen"],
          "note": "Rookie of the Year",
          "sourceUrl": "https://example.com/mama"
        }
      ]
      ''';

      final award = AssetAwardRepository.parseAwards(raw).single;

      expect(award.id, 'mama-2025');
      expect(award.title, 'Best New Artist');
      expect(award.ceremony, 'MAMA Awards');
      expect(award.year, 2025);
      expect(award.awardedOn, DateTime(2025, 11, 28));
      expect(award.work, 'The Chase');
      expect(award.members, ['Carmen']);
      expect(award.note, 'Rookie of the Year');
      expect(award.sourceUrl, 'https://example.com/mama');
      expect(award.isIndividual, isTrue);
    });

    test('defaults type to award and members to empty', () {
      const raw = '[{"id": "a", "title": "T", "ceremony": "C", "year": 2025}]';

      final award = AssetAwardRepository.parseAwards(raw).single;

      expect(award.type, Award.typeAward);
      expect(award.members, isEmpty);
      expect(award.isIndividual, isFalse);
      expect(award.awardedOn, isNull);
    });

    test('reads the music-show and milestone types', () {
      const raw = '''
      [
        {"id": "a", "title": "T", "ceremony": "C", "year": 2026, "type": "music-show"},
        {"id": "b", "title": "T", "ceremony": "C", "year": 2025, "type": "milestone"}
      ]
      ''';

      final awards = AssetAwardRepository.parseAwards(raw);

      expect(awards[0].type, Award.typeMusicShow);
      expect(awards[1].type, Award.typeMilestone);
    });

    test('rejects a non-https sourceUrl', () {
      const raw =
          '[{"id": "a", "title": "T", "ceremony": "C", "year": 2025, "sourceUrl": "http://example.com"}]';

      expect(
        () => AssetAwardRepository.parseAwards(raw),
        throwsFormatException,
      );
    });

    test('throws when a required field is missing', () {
      const raw = '[{"title": "No id", "ceremony": "C", "year": 2025}]';

      expect(
        () => AssetAwardRepository.parseAwards(raw),
        throwsA(isA<TypeError>()),
      );
    });

    test('throws FormatException when the root is not an array', () {
      expect(
        () => AssetAwardRepository.parseAwards('{"id": "x"}'),
        throwsFormatException,
      );
    });

    test('returns an empty list for an empty array', () {
      expect(AssetAwardRepository.parseAwards('[]'), isEmpty);
    });
  });

  group('AssetAwardRepository.getAwards', () {
    setUp(TestWidgetsFlutterBinding.ensureInitialized);

    test('loads the real bundled asset', () async {
      const repository = AssetAwardRepository();

      final awards = await repository.getAwards();

      // Not pinning an exact roster: the PO curates awards.json freely.
      expect(awards, isNotEmpty);
      expect(awards.every((a) => a.title.isNotEmpty), isTrue);
      expect(awards.every((a) => a.ceremony.isNotEmpty), isTrue);
      expect(awards.every((a) => a.year > 2000), isTrue);

      // Ids drive the detail route; duplicates would make one unreachable.
      expect(awards.map((a) => a.id).toSet(), hasLength(awards.length));
    });
  });
}
