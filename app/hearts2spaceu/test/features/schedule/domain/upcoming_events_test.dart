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

  test('keeps an all-day event for the whole day it happens on', () {
    // Regression: all-day events are stored at midnight, so comparing against
    // the current instant made them disappear at 00:01 on their own day.
    final today = _event('today', DateTime(2026, 6, 1));
    final lateInTheDay = DateTime(2026, 6, 1, 23, 59);

    expect(upcomingSorted([today], lateInTheDay), [today]);
  });

  test('keeps a timed event that already started today', () {
    // Regression: a 19:00 concert vanished at 19:01, while it was still on.
    final concert = _event('concert', DateTime(2026, 6, 1, 19));
    final duringTheShow = DateTime(2026, 6, 1, 20, 30);

    expect(upcomingSorted([concert], duringTheShow), [concert]);
  });

  test('drops an event once the day is over', () {
    final yesterday = _event('yesterday', DateTime(2026, 5, 31, 19));
    final nextMorning = DateTime(2026, 6, 1, 0, 1);

    expect(upcomingSorted([yesterday], nextMorning), isEmpty);
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
