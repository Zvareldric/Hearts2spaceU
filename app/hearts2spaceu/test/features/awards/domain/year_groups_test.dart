import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/features/awards/domain/award.dart';
import 'package:hearts2spaceu/features/awards/domain/year_groups.dart';

Award _award(String id, int year) =>
    Award(id: id, title: id, ceremony: 'Ceremony', year: year);

void main() {
  test('groups awards by year, newest year first', () {
    final years = groupByYear([
      _award('a', 2025),
      _award('b', 2026),
      _award('c', 2025),
    ]);

    expect(years.map((y) => y.year), [2026, 2025]);
    expect(years.first.awards.single.id, 'b');
    expect(years.last.awards.map((a) => a.id), ['a', 'c']);
  });

  test('keeps the source order within a year', () {
    // awards.json ordering is an editorial choice, and most entries have no
    // date precise enough to sort by anyway.
    final years = groupByYear([_award('second', 2026), _award('first', 2026)]);

    expect(years.single.awards.map((a) => a.id), ['second', 'first']);
  });

  test('gathers awards of the same year even when they are not adjacent', () {
    final years = groupByYear([
      _award('a', 2025),
      _award('b', 2026),
      _award('c', 2025),
      _award('d', 2026),
    ]);

    expect(years, hasLength(2));
    expect(years[0].awards.map((a) => a.id), ['b', 'd']);
    expect(years[1].awards.map((a) => a.id), ['a', 'c']);
  });

  test('does not mutate the input list', () {
    final awards = [_award('a', 2025), _award('b', 2026)];
    final snapshot = List.of(awards);

    groupByYear(awards);

    expect(awards, snapshot);
  });

  test('returns empty for empty input', () {
    expect(groupByYear(const []), isEmpty);
  });
}
