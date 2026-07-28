import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/features/latest_updates/domain/update.dart';
import 'package:hearts2spaceu/features/latest_updates/domain/update_repository.dart';
import 'package:hearts2spaceu/features/latest_updates/presentation/providers/update_providers.dart';

class _FakeUpdateRepository implements UpdateRepository {
  _FakeUpdateRepository(this._updates);

  final List<Update> _updates;

  @override
  Future<List<Update>> getUpdates() async => _updates;
}

class _ThrowingUpdateRepository implements UpdateRepository {
  @override
  Future<List<Update>> getUpdates() async => throw Exception('offline');
}

void main() {
  test('latestUpdatesProvider exposes updates newest first', () async {
    final container = ProviderContainer(
      overrides: [
        updateRepositoryProvider.overrideWithValue(
          _FakeUpdateRepository([
            Update(id: 'old', title: 'Old', publishedAt: DateTime(2026, 1, 1)),
            Update(id: 'new', title: 'New', publishedAt: DateTime(2026, 7, 1)),
            Update(id: 'mid', title: 'Mid', publishedAt: DateTime(2026, 4, 1)),
          ]),
        ),
      ],
    );
    addTearDown(container.dispose);

    final result = await container.read(latestUpdatesProvider.future);

    expect(result.map((u) => u.id), ['new', 'mid', 'old']);
  });

  test('latestUpdatesProvider surfaces repository errors', () async {
    final container = ProviderContainer(
      overrides: [
        updateRepositoryProvider.overrideWithValue(_ThrowingUpdateRepository()),
      ],
    );
    addTearDown(container.dispose);

    container.listen(latestUpdatesProvider, (_, _) {}, fireImmediately: true);
    await Future<void>.delayed(Duration.zero);

    final state = container.read(latestUpdatesProvider);
    expect(state.hasError, isTrue);
    expect(state.error, isA<Exception>());
  });
}
