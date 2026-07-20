import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/features/schedule/domain/event.dart';
import 'package:hearts2spaceu/features/schedule/domain/event_repository.dart';
import 'package:hearts2spaceu/features/schedule/presentation/pages/schedule_page.dart';
import 'package:hearts2spaceu/features/schedule/presentation/providers/event_providers.dart';
import 'package:hearts2spaceu/features/schedule/presentation/widgets/empty_view.dart';
import 'package:hearts2spaceu/features/schedule/presentation/widgets/error_view.dart';
import 'package:hearts2spaceu/features/schedule/presentation/widgets/event_card.dart';
import 'package:hearts2spaceu/routes/app_router.dart';

class _FakeEventRepository implements EventRepository {
  _FakeEventRepository(this.events);

  final List<Event> events;

  @override
  Future<List<Event>> getEvents() async => events;
}

class _ThrowingEventRepository implements EventRepository {
  @override
  Future<List<Event>> getEvents() async => throw Exception('boom');
}

class _DelayedEventRepository implements EventRepository {
  _DelayedEventRepository(this.events);

  final List<Event> events;

  @override
  Future<List<Event>> getEvents() =>
      Future.delayed(const Duration(seconds: 1), () => events);
}

/// Fails the first call, then succeeds — to exercise Retry.
class _FlakyEventRepository implements EventRepository {
  _FlakyEventRepository(this.events);

  final List<Event> events;
  bool _firstAttempt = true;

  @override
  Future<List<Event>> getEvents() async {
    if (_firstAttempt) {
      _firstAttempt = false;
      throw Exception('first attempt fails');
    }
    return events;
  }
}

Widget _app(EventRepository repository) {
  return ProviderScope(
    overrides: [eventRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(
      onGenerateRoute: AppRouter.onGenerateRoute,
      home: const SchedulePage(),
    ),
  );
}

List<Event> _futureEvents() {
  final now = DateTime.now();
  return [
    Event(
      id: 'e1',
      title: 'Alpha Show',
      startDateTime: now.add(const Duration(days: 1)),
    ),
    Event(
      id: 'e2',
      title: 'Beta Show',
      startDateTime: now.add(const Duration(days: 2)),
    ),
  ];
}

void main() {
  testWidgets('Loading — shows a spinner while fetching', (tester) async {
    await tester.pumpWidget(_app(_DelayedEventRepository(const [])));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  });

  testWidgets('Data — shows a card per upcoming event', (tester) async {
    await tester.pumpWidget(_app(_FakeEventRepository(_futureEvents())));
    await tester.pumpAndSettle();

    expect(find.byType(EventCard), findsNWidgets(2));
    expect(find.text('Alpha Show'), findsOneWidget);
    expect(find.text('Beta Show'), findsOneWidget);
  });

  testWidgets('Empty — shows the empty state for no upcoming events', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_FakeEventRepository(const [])));
    await tester.pumpAndSettle();

    expect(find.byType(EmptyView), findsOneWidget);
    expect(find.text('No upcoming events.'), findsOneWidget);
  });

  testWidgets('Error — shows the error state on failure', (tester) async {
    await tester.pumpWidget(_app(_ThrowingEventRepository()));
    await tester.pumpAndSettle();

    expect(find.byType(ErrorView), findsOneWidget);
    expect(find.text('Failed to load the schedule.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('Retry — Error → Retry → Data', (tester) async {
    await tester.pumpWidget(_app(_FlakyEventRepository(_futureEvents())));
    await tester.pumpAndSettle();

    expect(find.byType(ErrorView), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.byType(ErrorView), findsNothing);
    expect(find.byType(EventCard), findsNWidgets(2));
  });

  testWidgets('Navigation — List → Detail → Back', (tester) async {
    await tester.pumpWidget(_app(_FakeEventRepository(_futureEvents())));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Alpha Show'));
    await tester.pumpAndSettle();

    expect(find.text('Event'), findsOneWidget); // detail AppBar title
    expect(find.text('Alpha Show'), findsOneWidget); // event title on detail

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.byType(SchedulePage), findsOneWidget);
  });

  testWidgets('Past events are not shown', (tester) async {
    final now = DateTime.now();
    final repository = _FakeEventRepository([
      Event(
        id: 'past',
        title: 'Past Show',
        startDateTime: now.subtract(const Duration(days: 1)),
      ),
      Event(
        id: 'future',
        title: 'Future Show',
        startDateTime: now.add(const Duration(days: 1)),
      ),
    ]);

    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    expect(find.byType(EventCard), findsOneWidget);
    expect(find.text('Future Show'), findsOneWidget);
    expect(find.text('Past Show'), findsNothing);
  });
}
