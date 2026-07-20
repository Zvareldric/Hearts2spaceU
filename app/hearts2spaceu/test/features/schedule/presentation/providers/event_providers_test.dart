import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/features/schedule/domain/event.dart';
import 'package:hearts2spaceu/features/schedule/domain/event_repository.dart';
import 'package:hearts2spaceu/features/schedule/presentation/providers/event_providers.dart';

class _FakeEventRepository implements EventRepository {
  _FakeEventRepository(this._events);

  final List<Event> _events;

  @override
  Future<List<Event>> getEvents() async => _events;
}

class _ThrowingEventRepository implements EventRepository {
  @override
  Future<List<Event>> getEvents() async => throw Exception('boom');
}

void main() {
  test(
    'upcomingEventsProvider exposes upcoming events, sorted, past excluded',
    () async {
      final now = DateTime.now();
      final container = ProviderContainer(
        overrides: [
          eventRepositoryProvider.overrideWithValue(
            _FakeEventRepository([
              Event(
                id: 'past',
                title: 'Past',
                startDateTime: now.subtract(const Duration(days: 1)),
              ),
              Event(
                id: 'later',
                title: 'Later',
                startDateTime: now.add(const Duration(days: 2)),
              ),
              Event(
                id: 'soon',
                title: 'Soon',
                startDateTime: now.add(const Duration(days: 1)),
              ),
            ]),
          ),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(upcomingEventsProvider.future);

      expect(result.map((e) => e.id), ['soon', 'later']);
    },
  );

  test('upcomingEventsProvider surfaces repository errors', () async {
    final container = ProviderContainer(
      overrides: [
        eventRepositoryProvider.overrideWithValue(_ThrowingEventRepository()),
      ],
    );
    addTearDown(container.dispose);

    container.listen(upcomingEventsProvider, (_, _) {}, fireImmediately: true);
    await Future<void>.delayed(Duration.zero);

    final state = container.read(upcomingEventsProvider);
    expect(state.hasError, isTrue);
    expect(state.error, isA<Exception>());
  });
}
