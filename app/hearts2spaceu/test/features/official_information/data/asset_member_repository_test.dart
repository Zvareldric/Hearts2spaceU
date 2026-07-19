import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/features/official_information/data/asset_member_repository.dart';

void main() {
  group('AssetMemberRepository.parseMembers', () {
    test('parses a fully-populated member', () {
      const raw = '''
      [
        {
          "id": "m1",
          "stageName": "Alpha",
          "fullName": "Alpha Full",
          "birthDate": "2005-01-02",
          "positions": ["Vocalist", "Dancer"],
          "profileImage": null,
          "officialProfileUrl": "https://example.com/alpha"
        }
      ]
      ''';

      final members = AssetMemberRepository.parseMembers(raw);

      expect(members, hasLength(1));
      final member = members.first;
      expect(member.id, 'm1');
      expect(member.stageName, 'Alpha');
      expect(member.fullName, 'Alpha Full');
      expect(member.birthDate, DateTime(2005, 1, 2));
      expect(member.positions, ['Vocalist', 'Dancer']);
      expect(member.profileImage, isNull);
      expect(member.officialProfileUrl, 'https://example.com/alpha');
    });

    test('defaults optional fields when absent', () {
      const raw = '[{"id": "m2", "stageName": "Beta"}]';

      final member = AssetMemberRepository.parseMembers(raw).single;

      expect(member.fullName, isNull);
      expect(member.birthDate, isNull);
      expect(member.positions, isEmpty);
      expect(member.profileImage, isNull);
      expect(member.officialProfileUrl, isNull);
    });

    test('returns an empty list for an empty array', () {
      expect(AssetMemberRepository.parseMembers('[]'), isEmpty);
    });

    test('throws FormatException when the root is not an array', () {
      expect(
        () => AssetMemberRepository.parseMembers('{"id": "x"}'),
        throwsFormatException,
      );
    });

    test('throws when a required field is missing', () {
      expect(
        () => AssetMemberRepository.parseMembers('[{"stageName": "NoId"}]'),
        throwsA(isA<TypeError>()),
      );
    });
  });

  group('AssetMemberRepository.getMembers', () {
    setUp(TestWidgetsFlutterBinding.ensureInitialized);

    test('loads the bundled asset (currently empty)', () async {
      const repository = AssetMemberRepository();

      final members = await repository.getMembers();

      expect(members, isEmpty);
    });
  });
}
