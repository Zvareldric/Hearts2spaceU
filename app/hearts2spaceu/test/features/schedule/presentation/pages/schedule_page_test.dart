import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hearts2spaceu/features/schedule/domain/event.dart';
import 'package:hearts2spaceu/features/schedule/domain/event_repository.dart';
import 'package:hearts2spaceu/app/widgets/states/empty_view.dart';
import 'package:hearts2spaceu/app/widgets/states/error_view.dart';
import 'package:hearts2spaceu/features/schedule/presentation/pages/event_detail_page.dart';
import 'package:hearts2spaceu/features/schedule/presentation/pages/schedule_page.dart';
import 'package:hearts2spaceu/features/schedule/presentation/providers/event_providers.dart';
import 'package:hearts2spaceu/features/schedule/presentation/widgets/event_card.dart';
import 'package:hearts2spaceu/routes/app_router.dart';

class _FakeEventRepository implements EventRepository {
  _FakeEventRepository(this.events);

  final List<Event> events;

  @override
  Future<List<Event>> getEvents({bool forceRefresh = false}) async => events;
}

class _ThrowingEventRepository implements EventRepository {
  @override
  Future<List<Event>> getEvents({bool forceRefresh = false}) async =>
      throw Exception('boom');
}

class _DelayedEventRepository implements EventRepository {
  _DelayedEventRepository(this.events);

  final List<Event> events;

  @override
  Future<List<Event>> getEvents({bool forceRefresh = false}) =>
      Future.delayed(const Duration(seconds: 1), () => events);
}

/// Fails the first call, then succeeds — to exercise Retry.
class _FlakyEventRepository implements EventRepository {
  _FlakyEventRepository(this.events);

  final List<Event> events;
  bool _firstAttempt = true;

  @override
  Future<List<Event>> getEvents({bool forceRefresh = false}) async {
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

    // Structural: the detail page no longer carries an AppBar title — its
    // hero does (Design System V1, Checkpoint 6).
    expect(find.byType(EventDetailPage), findsOneWidget);
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

  testWidgets('a dual-zone time and a place still fit a card at 360dp', (
    tester,
  ) async {
    // The card's meta line grew from "18:00" to "16:00 WIB (18:00 KST)" when
    // zones arrived. The narrowest phone width is where that has to hold.
    tester.view
      ..physicalSize = const Size(360, 800)
      ..devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final now = DateTime.now();
    await tester.pumpWidget(
      _app(
        _FakeEventRepository([
          Event(
            id: 'tokyo',
            title: "'ICONIC HEART' Fansign Event in Tokyo Day 1",
            startDateTime: now.add(const Duration(days: 2)),
            type: 'fansign',
            location: 'Tokyo, Japan',
            zoneLabel: 'JST',
            zoneOffset: now.timeZoneOffset + const Duration(hours: 2),
          ),
        ]),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(EventCard), findsOneWidget);
  });

  testWidgets('a schedule card remains usable at 200% text scale', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view
      ..physicalSize = const Size(360, 800)
      ..devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final now = DateTime.now();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          eventRepositoryProvider.overrideWithValue(
            _FakeEventRepository([
              Event(
                id: 'large-text',
                title: 'A very long activity title remains readable',
                startDateTime: now.add(const Duration(days: 2)),
                type: 'fanmeeting',
                location: 'Tokyo, Japan',
                zoneLabel: 'JST',
                zoneOffset: now.timeZoneOffset + const Duration(hours: 2),
              ),
            ]),
          ),
        ],
        child: MaterialApp(
          onGenerateRoute: AppRouter.onGenerateRoute,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: const SchedulePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      find.text('A very long activity title remains readable'),
      findsOneWidget,
    );
  });

  testWidgets('month headers follow a text size change made while open', (
    tester,
  ) async {
    // What happens when a reader changes the system font size with the app in
    // the foreground. The pinned header's height depends on text size, but it
    // only rebuilt when its label changed — so it kept its old height, and
    // Flutter rejected the header's geometry outright.
    SharedPreferences.setMockInitialValues({});
    final textScale = ValueNotifier<double>(1);
    addTearDown(textScale.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          eventRepositoryProvider.overrideWithValue(
            _FakeEventRepository(_futureEvents()),
          ),
        ],
        child: MaterialApp(
          onGenerateRoute: AppRouter.onGenerateRoute,
          builder: (context, child) => ValueListenableBuilder<double>(
            valueListenable: textScale,
            builder: (context, scale, _) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
          ),
          home: const SchedulePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    textScale.value = 2;
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(EventCard), findsWidgets);
  });
}
