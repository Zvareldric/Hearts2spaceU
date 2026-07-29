import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearts2spaceu/features/collection/data/prefs_favorites_repository.dart';
import 'package:hearts2spaceu/features/collection/domain/favorite.dart';
import 'package:hearts2spaceu/features/collection/domain/favorites_repository.dart';
import 'package:hearts2spaceu/features/collection/presentation/providers/favorites_providers.dart';
import 'package:hearts2spaceu/features/collection/presentation/widgets/favorite_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stands in for the real store; no test ever touches device storage.
class _InMemoryRepository implements FavoritesRepository {
  _InMemoryRepository([Set<String>? initial]) : saved = {...?initial};

  Set<String> saved;

  @override
  Future<Set<String>> load() async => saved;

  @override
  Future<void> save(Set<String> keys) async => saved = {...keys};
}

Widget _button(FavoritesRepository repository, Favorite favorite) {
  return ProviderScope(
    overrides: [favoritesRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(
      home: Scaffold(
        body: FavoriteButton(type: favorite.type, id: favorite.id),
      ),
    ),
  );
}

void main() {
  group('Favorite.tryParse', () {
    test('splits type from id', () {
      final f = Favorite.tryParse('event:tima-2026')!;
      expect(f.type, 'event');
      expect(f.id, 'tima-2026');
    });

    test('keeps colons inside the id', () {
      // Ids come from curated data and may contain ':' themselves.
      expect(Favorite.tryParse('photo:album:01')!.id, 'album:01');
    });

    test('returns null for malformed keys', () {
      // One bad entry must never take the whole collection down.
      for (final bad in ['', 'nocolon', ':leading', 'trailing:']) {
        expect(Favorite.tryParse(bad), isNull, reason: bad);
      }
    });

    test('round-trips through key', () {
      const f = Favorite(type: Favorite.typePhoto, id: 'lemon-tang/01');
      expect(Favorite.tryParse(f.key), f);
    });
  });

  group('PrefsFavoritesRepository', () {
    test('returns empty when nothing is stored', () async {
      SharedPreferences.setMockInitialValues({});
      expect(await const PrefsFavoritesRepository().load(), isEmpty);
    });

    test('round-trips a saved set', () async {
      SharedPreferences.setMockInitialValues({});
      const repository = PrefsFavoritesRepository();

      await repository.save({'award:a', 'event:b'});

      expect(await repository.load(), {'award:a', 'event:b'});
    });

    test('reads corrupt storage as empty instead of crashing', () async {
      SharedPreferences.setMockInitialValues({
        PrefsFavoritesRepository.storageKey: 'not json at all',
      });

      expect(await const PrefsFavoritesRepository().load(), isEmpty);
    });

    test('ignores non-string entries', () async {
      SharedPreferences.setMockInitialValues({
        PrefsFavoritesRepository.storageKey: jsonEncode(['award:a', 42, null]),
      });

      expect(await const PrefsFavoritesRepository().load(), {'award:a'});
    });
  });

  group('FavoriteButton', () {
    const favorite = Favorite(type: Favorite.typeAward, id: 'mama-2025');

    testWidgets('starts unfilled and fills when tapped', (tester) async {
      final repository = _InMemoryRepository();
      await tester.pumpWidget(_button(repository, favorite));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
      expect(repository.saved, {'award:mama-2025'});
    });

    testWidgets('starts filled for an already-saved item', (tester) async {
      // Persistence: what a previous session saved shows up filled on launch.
      final repository = _InMemoryRepository({'award:mama-2025'});
      await tester.pumpWidget(_button(repository, favorite));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    });

    testWidgets('unfills and clears storage when tapped again', (tester) async {
      final repository = _InMemoryRepository({'award:mama-2025'});
      await tester.pumpWidget(_button(repository, favorite));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
      expect(repository.saved, isEmpty);
    });
  });
}
