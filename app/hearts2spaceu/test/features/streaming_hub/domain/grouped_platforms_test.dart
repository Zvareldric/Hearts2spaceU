import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/features/streaming_hub/domain/grouped_platforms.dart';
import 'package:hearts2spaceu/features/streaming_hub/domain/official_platform.dart';

OfficialPlatform _platform(String id, String category) => OfficialPlatform(
  id: id,
  name: id,
  url: 'https://example.com/$id',
  category: category,
);

void main() {
  test('groups platforms by category', () {
    final grouped = groupByCategory([
      _platform('spotify', 'music'),
      _platform('youtube', 'video'),
      _platform('instagram', 'social'),
    ]);

    expect(grouped.keys, ['music', 'video', 'social']);
    expect(grouped['music']!.single.id, 'spotify');
  });

  test('orders categories by platformCategoryOrder, not by input order', () {
    final grouped = groupByCategory([
      _platform('instagram', 'social'),
      _platform('spotify', 'music'),
      _platform('youtube', 'video'),
    ]);

    expect(grouped.keys, ['music', 'video', 'social']);
  });

  test('preserves source order within a category', () {
    // platforms.json ordering is a curation decision, not an accident.
    final grouped = groupByCategory([
      _platform('second', 'social'),
      _platform('first', 'social'),
    ]);

    expect(grouped['social']!.map((p) => p.id), ['second', 'first']);
  });

  test('omits categories that have no platforms', () {
    final grouped = groupByCategory([_platform('spotify', 'music')]);

    expect(grouped.keys, ['music']);
    expect(grouped.containsKey('community'), isFalse);
  });

  test('keeps unknown categories, after the known ones', () {
    // New data should never silently disappear from the UI.
    final grouped = groupByCategory([
      _platform('mystery', 'podcast'),
      _platform('spotify', 'music'),
    ]);

    expect(grouped.keys, ['music', 'podcast']);
    expect(grouped['podcast']!.single.id, 'mystery');
  });

  test('returns empty for empty input', () {
    expect(groupByCategory(const []), isEmpty);
  });
}
