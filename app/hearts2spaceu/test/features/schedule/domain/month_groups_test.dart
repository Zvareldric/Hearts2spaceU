import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/features/schedule/domain/event.dart';
import 'package:hearts2spaceu/features/schedule/domain/month_groups.dart';

Event _event(String id, DateTime start) =>
    Event(id: id, title: id, startDateTime: start);

void main() {
  test('splits events into calendar months', () {
    final groups = groupByMonth([
      _event('jul-a', DateTime(2026, 7, 29)),
      _event('aug-a', DateTime(2026, 8, 5)),
      _event('aug-b', DateTime(2026, 8, 12)),
      _event('sep-a', DateTime(2026, 9, 19)),
    ]);

    expect(groups, hasLength(3));
    expect(groups[0].month, 7);
    expect(groups[1].events.map((e) => e.id), ['aug-a', 'aug-b']);
    expect(groups[2].month, 9);
  });

  test('keeps the given order rather than sorting', () {
    // The provider hands over an already-sorted list; grouping must not
    // silently reorder it.
    final groups = groupByMonth([
      _event('later', DateTime(2026, 8, 20)),
      _event('earlier', DateTime(2026, 8, 5)),
    ]);

    expect(groups.single.events.map((e) => e.id), ['later', 'earlier']);
  });

  test('separates the same month in different years', () {
    final groups = groupByMonth([
      _event('2026', DateTime(2026, 8, 5)),
      _event('2027', DateTime(2027, 8, 5)),
    ]);

    expect(groups, hasLength(2));
    expect(groups[0].year, 2026);
    expect(groups[1].year, 2027);
  });

  test('does not mutate the input list', () {
    final events = [_event('a', DateTime(2026, 8, 5))];
    final snapshot = List.of(events);

    groupByMonth(events);

    expect(events, snapshot);
  });

  test('returns empty for empty input', () {
    expect(groupByMonth(const []), isEmpty);
  });
}
