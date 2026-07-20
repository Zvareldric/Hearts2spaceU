import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/features/schedule/domain/event.dart';
import 'package:hearts2spaceu/features/schedule/domain/upcoming_events.dart';

Event _event(String id, DateTime start) =>
    Event(id: id, title: id, startDateTime: start);

void main() {
  final now = DateTime(2026, 6, 1, 12, 0);

  test('excludes past events, keeps now and future', () {
    final events = [
      _event('past', now.subtract(const Duration(days: 1))),
      _event('nowish', now),
      _event('future', now.add(const Duration(days: 1))),
    ];

    final result = upcomingSorted(events, now);

    expect(result.map((e) => e.id), ['nowish', 'future']);
  });

  test('sorts ascending by startDateTime', () {
    final events = [
      _event('c', now.add(const Duration(days: 3))),
      _event('a', now.add(const Duration(days: 1))),
      _event('b', now.add(const Duration(days: 2))),
    ];

    final result = upcomingSorted(events, now);

    expect(result.map((e) => e.id), ['a', 'b', 'c']);
  });

  test('keeps source order for equal times (stable sort)', () {
    final at = now.add(const Duration(days: 1));
    final events = [
      _event('first', at),
      _event('second', at),
      _event('third', at),
    ];

    final result = upcomingSorted(events, now);

    expect(result.map((e) => e.id), ['first', 'second', 'third']);
  });

  test('does not mutate the input list', () {
    final events = [
      _event('b', now.add(const Duration(days: 2))),
      _event('a', now.add(const Duration(days: 1))),
    ];
    final snapshot = List.of(events);

    upcomingSorted(events, now);

    expect(events, snapshot); // original order & contents unchanged
  });

  test('returns empty for empty input', () {
    expect(upcomingSorted(const [], now), isEmpty);
  });
}
