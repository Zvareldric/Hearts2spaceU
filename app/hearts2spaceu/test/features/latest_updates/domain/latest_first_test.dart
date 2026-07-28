import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/features/latest_updates/domain/latest_first.dart';
import 'package:hearts2spaceu/features/latest_updates/domain/update.dart';

Update _update(String id, DateTime publishedAt) =>
    Update(id: id, title: id, publishedAt: publishedAt);

void main() {
  final base = DateTime(2026, 6, 1, 12);

  test('sorts newest first', () {
    final updates = [
      _update('oldest', base.subtract(const Duration(days: 3))),
      _update('newest', base),
      _update('middle', base.subtract(const Duration(days: 1))),
    ];

    final result = latestFirst(updates);

    expect(result.map((u) => u.id), ['newest', 'middle', 'oldest']);
  });

  test('keeps source order for equal timestamps (stable sort)', () {
    final updates = [
      _update('first', base),
      _update('second', base),
      _update('third', base),
    ];

    final result = latestFirst(updates);

    expect(result.map((u) => u.id), ['first', 'second', 'third']);
  });

  test('keeps every update — nothing is filtered out by date', () {
    // Unlike the schedule, past updates stay relevant.
    final updates = [
      _update('long-ago', DateTime(2020)),
      _update('future-dated', DateTime(2030)),
    ];

    expect(latestFirst(updates), hasLength(2));
  });

  test('does not mutate the input list', () {
    final updates = [
      _update('a', base.subtract(const Duration(days: 1))),
      _update('b', base),
    ];
    final snapshot = List.of(updates);

    latestFirst(updates);

    expect(updates, snapshot);
  });

  test('returns empty for empty input', () {
    expect(latestFirst(const []), isEmpty);
  });
}
